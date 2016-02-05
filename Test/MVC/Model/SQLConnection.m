//
//  SQLConnection.m
//

#import "SQLConnection.h"
#import <sqlite3.h>

#define DBNAME    @"Data.db"

@implementation SQLConnection


#pragma mark -
#pragma mark SQL Lite data source

- (NSString *)createDBWithName
{
    // Get the path to the documents directory and append the databaseName
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:DBNAME];
    return databasePath;
}


-(void) CreateDatabase
{

    BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:[self createDBWithName]];
	
	// If the database already exists then return without doing anything
	if(success) 
    {
        [fileManager removeItemAtPath:[self createDBWithName] error:nil];
    }
	

	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBNAME];
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:[self createDBWithName] error:nil];
	
}

-(void) checkAndCreateDatabase 
{
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:[self createDBWithName]];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBNAME];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:[self createDBWithName] error:nil];

}


-(NSMutableArray*) GetFromDatabase:(NSString *)strQuery
{
	// Setup the database object
	sqlite3 *database;
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    // Open the database from the users filessytem
	if(sqlite3_open([[self createDBWithName] UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *statement = strQuery;
		const char *sqlStatement = (const char *) [statement UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
           
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                for (int colCount=0; colCount<sqlite3_column_count(compiledStatement); colCount++)
                {
                    const char *strKey = sqlite3_column_name(compiledStatement, colCount);
                    switch (sqlite3_column_type(compiledStatement,colCount))
                    {
                        case SQLITE_TEXT:
                        {
                            const char *strValue = (char *) sqlite3_column_text(compiledStatement, colCount);
                            NSString *key = [[NSString alloc] initWithUTF8String:strKey];
                            NSString *value = @"";
                            if (strValue)
                            {
                                value = [[NSString alloc] initWithUTF8String:strValue];
                            }
                            
                            [dict setObject:value forKey:key];
                        }
                            break;
                        case SQLITE_INTEGER:
                        {
                            int intValue = sqlite3_column_int(compiledStatement, colCount);
                            NSString *key = [[NSString alloc] initWithUTF8String:strKey];
                            NSString *value = [[NSString alloc] initWithFormat:@"%d",intValue];
                            [dict setObject:value forKey:key];
                        }
                            break;
                        default:
                        {
                            const char *strValue = (char *) sqlite3_column_text(compiledStatement, colCount);
                            NSString *key = [[NSString alloc] initWithUTF8String:strKey];
                            NSString *value = @"";
                            if (strValue)
                            {
                                value = [[NSString alloc] initWithUTF8String:strValue];
                            }
                            [dict setObject:value forKey:key];
                        }
                            break;
                    }
                }
                
                [retval addObject:dict];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return retval;
	
}

-(void) insertToDatabase:(NSString *)strQuery
{
	sqlite3 *database;
	
	// Open the database from the users filessytem
	if(sqlite3_open([[self createDBWithName] UTF8String], &database) == SQLITE_OK)
	{
		static sqlite3_stmt *compiledStatement;
		sqlite3_exec(database, [[NSString stringWithFormat:@"%@",strQuery] UTF8String], NULL, NULL, NULL);
		sqlite3_finalize(compiledStatement);
	}
    else
    {

    }
	sqlite3_close(database);
	
}


-(void) updateDatabase:(NSString *)strQuery
{
	sqlite3 *database;
	
	// Open the database from the users filessytem
	if(sqlite3_open([[self createDBWithName] UTF8String], &database) == SQLITE_OK)
	{
		static sqlite3_stmt *compiledStatement;
        sqlite3_exec(database, [[NSString stringWithFormat:@"%@",strQuery] UTF8String], NULL, NULL, NULL);
		sqlite3_finalize(compiledStatement);
	}
    else
    {

    }
	sqlite3_close(database);
	
}

-(void) deleteFromDatabase:(NSString *)strQuery
{
	sqlite3 *database;
	if(sqlite3_open([[self createDBWithName] UTF8String], &database) == SQLITE_OK)
	{
        sqlite3_exec(database, [[NSString stringWithFormat:@"%@",strQuery] UTF8String], NULL, NULL, NULL);
        sqlite3_close(database);
		
	}
    else
    {

    }	
}

@end
