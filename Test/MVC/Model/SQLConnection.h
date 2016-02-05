//
//  SQLConnection.h
//

#import <Foundation/Foundation.h>

@interface SQLConnection : NSObject
{
}

- (NSString *)createDBWithName;
-(void) checkAndCreateDatabase ;
-(void) CreateDatabase;
-(NSMutableArray *) GetFromDatabase:(NSString *)strQuery;
-(void) insertToDatabase:(NSString *)strQuery;
-(void) updateDatabase:(NSString *)strQuery;
-(void) deleteFromDatabase:(NSString *)strQuery;

@end
