import json
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import * 

''' 
 loadSettings method - this is to load information on what needs to be normialized
'''
def loadSettings(settingsPath = "normalizationData.json"):
    # Deserialize JSON input data
    try:
        with open(settingsPath, "r") as settingsFile:
            settings = json.load(settingsFile)
        
        # Verify if all columns have mappings assigned
        if set(settings.get("attributes4Normalization")) == set(settings.get("mappingsData").keys()):
            return settings
        else: # let's raise built-in exception complaining on discrepancy of column mapping info 
            raise ValueError("Exception: column mapping information discrepancy detected!")
        
    except ValueError as e:
        print(e)

''' 
 normalizeData method - this is to focus on data normalization
'''
def normalizeData(value, attributesForNormalization, mappingInformation):
    # let's load column settings for normalization purposes
    settings = mappingInformation.get(attributesForNormalization)

    # let 's check if there is a mapped value - if it is, let's use it
    if value in settings.keys():
        return settings.get(value)
    elif settings.get(value) == value:
        return value 
    else: 
        return "Other"

''' 
 applyNormalization method - this is to normalize some data of MakeText and BodyColorText 
 in case if more normalization is required, one needs to modify the settings 
 in loadSettings method / normalizationData.json file
'''
def applyNormalization(dataFrame, attributesForNormalization, mappingInformation):
    # local data frame for in-place changes 
    normalizedDF = dataFrame
    
    for attribute in attributesForNormalization:
        # define Spark UDF and call normalizeData method for particular attribute - to speed up the process
        # solution partially based on https://changhsinlee.com/pyspark-udf/
        normalizeAttribute = udf(lambda lmbdMJ4OneDot: normalizeData(lmbdMJ4OneDot, attribute, mappingInformation), StringType())
        # apply normalization for the current attribute
        normalizedDF = normalizedDF.withColumn(attribute, normalizeAttribute(dataFrame[attribute]))
        
    return normalizedDF

''' 
 applySchema method - to enforce schema changes if required 
'''
def applySchema(dataFrame, tableName):

    with open("targetSchema.json", "r") as targetFile:
        json_schema = json.load(targetFile)

    # ler's obtain expected schema details
    expectedSchema = StructType.fromJson(json_schema[tableName])

    # let's check if schema match - if it is -> return dataFrame not changed
    if set(expectedSchema) == set(dataFrame.schema):
        return dataFrame
    # in case if we experience data type differences - let's try cast them
    elif set(dataFrame.columns) == set(expectedSchema.names):
        # let's cast / enforce expectedSchema
        for field in expectedSchema:
            column_name = str(field.name)
            # let's ignore correct data types
            if dataFrame.schema[column_name].dataType == field.dataType:
                continue

            dataFrame = dataFrame.withColumn(column_name, col(column_name).cast(str(field.dataType).replace("Type", "")))
        return dataFrame
        # schema discrepancy detected - let's see some more details around
    else:
        dataFrameColumns = set(dataFrame.columns)
        expectedSchemaColumns = set(expectedSchema.names)
        # let's check what are differences between data frame and actually expected schema columns
        dataFrame2SchemaDiff = dataFrameColumns - expectedSchemaColumns
        # and let's have a look opposite - what is difference between schema columns and data frame
        schema2DataFrameDiff = expectedSchemaColumns - dataFrameColumns
        if (len(dataFrame2SchemaDiff) == 0) & (len(schema2DataFrameDiff) != 0):
            raise Exception(f"Exception - columns discrepancy: {schema2DataFrameDiff} exist in expectedSchema but cannot be found in dataFrame")
        elif (len(dataFrame2SchemaDiff) != 0) & (len(schema2DataFrameDiff) == 0):
            raise Exception(f"Exception - column discrepancy: {dataFrame2SchemaDiff} exist in dataFrame but cannot be found in expectedSchema")
        else:
            raise Exception(f"Exception - column name discrepancy between dataFrame and expectedSchema")

''' 
 Initialization / starting point of the script
'''
print('Spark initialization...')
# spark stuff
spark = SparkSession.builder.appName('OneDotRecruitmentTask!').master('local').getOrCreate()

print('Loading required settings...')
# load settings 
settings = loadSettings()

'''
 Step 1 - pre-process json data (ensuring encoding as requested in task description)
'''
print('STEP 1 - pre-processing...')
source_df = spark.read.option("escape", "\\").json("supplier_car.json", encoding = 'UTF-8')

# Pivot to get desired granularity as target data
preprocessingDF = source_df.groupBy("ID", "MakeText", "ModelText", "ModelTypeText", "TypeName", "TypeNameFull").pivot("Attribute Names").agg(first("Attribute Values")) 

# Actual preprocess - (force to 1 csv file - using repartition method, default 200)
preprocessingDF.repartition(1).write.mode("overwrite").option("header", "true").csv("csv/01_preprocess", encoding='UTF-8')

''' 
 Step 2 - normalize
'''
print('STEP 2 - normalizing...')
# let's apply normalization rules to preprocessed data frame
normalizedDF = applyNormalization(preprocessingDF, settings.get("attributes4Normalization"), settings.get("mappingsData"))
# let's write result to csv file (force to 1 csv file - using repartition method, default 200)
normalizedDF.repartition(1).write.mode("overwrite").option("header", "true").option("encoding", "UTF-8").csv("csv/02_normalize")

'''
 Step 3 - extract
'''
print('STEP 3 - extracting...')
extractedDF = normalizedDF.withColumn("value-ConsumptionTotalText", split(normalizedDF["ConsumptionTotalText"], " ")[0]).withColumn("unit-ConsumptionTotalText", split(normalizedDF["ConsumptionTotalText"], " ")[1]).drop("ConsumptionTotalText")

# Actual extraction - write to file (force to 1 csv file - using repartition method, default 200)
extractedDF.repartition(1).write.mode("overwrite").option("header", "true").option("encoding", "UTF-8").csv("csv/03_extract")

'''
 Step 4 - Integrate
'''
print('STEP 4 - integrating...')
# let's load integration dependencies from json file
# namely: what columns to be removed, renamed and added
with open("adjustmentData.json", "r") as integrationInformationFile:
    integrationInfo = json.load(integrationInformationFile)

# let's remove not required columns as per the json file information
integrationDF = extractedDF.drop(*integrationInfo.get("toBeRemoved"))

# let's rename columns (as per the json file information) so that it match requirements
for key, value in integrationInfo.get("toBeRenamed").items():
    integrationDF = integrationDF.withColumnRenamed(key, value)

# let's add missing columns to the dataframe (as per the json file information)
for key, value in integrationInfo.get("toBeAdded").items():
    integrationDF = integrationDF.withColumn(key, lit(value))

# let's have a look at data frame schema and force changes if required
integrationDF = applySchema(integrationDF, "target")

# Actual integration result - write to file (force to 1 csv file - using repartition method, default 200)
integrationDF.repartition(1).write.mode("overwrite").option("header", "true").option("encoding", "UTF-8").csv("csv/04_integrate")

print('Completed')

'''
 Step 5 - no code - just some verbal / written proposal out of this file
'''
