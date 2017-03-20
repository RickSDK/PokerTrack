//
//  ProjectFunctions.h
//  PokerTracker
//
//  Created by Rick Medved on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationGetter.h"
#import "ChipStackObj.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"


#define kStartTime		0
#define kEndTime		1
#define kHoursPlayed	2
#define kbuyIn			3
#define kRebuy			4
#define kFood			5
#define kCashOut		6
#define kWinnings		7
#define kGameMode		8
#define kGame			9
#define kBlinds			10
#define kLimit			11
#define kLocation		12
#define kBankroll		13
#define kNumRebuys		14
#define kNotes			15
#define kbreakMinutes	16
#define kdealertokes	17

#define kminutes		18
#define kYear			19
#define kType			20
#define kStatus			21
#define kTourneyType	22



//----------Edit in Here---------------------------
//#define kVersion    @"Version 6.8.3" using standard function now
#define kLOG 0
#define kPRODMode 1
#define kIsLiteVersion 0  // 0 or 1
//----------Edit in Here---------------------------

//Lite: 488925221
//Pro:	475160109

#define APPIRATER_APP_ID				475160109

//Lite: Poker Track Lite
//Pro:	Poker Track Pro

#define APPIRATER_APP_NAME				@"Poker Track Pro"



@interface ProjectFunctions : UIViewController {

}

+(int)getProductionMode;
+(BOOL)isLiteVersion;
+(BOOL)isPokerZilla;
+(NSString *)getAppID;
+(void)writeAppReview;
+(NSString *)getProjectVersion;
+(NSString *)getProjectDisplayVersion;
+(float)projectVersionNumber;
+(BOOL)useThreads;
+(NSArray *)getFieldListForVersion:(NSString *)version type:(NSString *)type;
+(NSArray *)sortArray:(NSMutableArray *)list;
+(NSArray *)sortArrayDescending:(NSArray *)list;
+(NSString *)getWinLossStreakString:(int)streak;
+(NSString *)getYearString:(int)year;
+(NSString *)getBasicPredicateString:(int)year type:(NSString *)Type;
+(NSString *)getPredicateString:(NSArray *)formDataArray mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum;
+(NSString *)convertIntToMoneyString:(double)money;
+(NSArray *)getArrayForSegment:(int)segment;
+(NSArray *)getColumnListForEntity:(NSString *)entityName type:(NSString *)type;
+(BOOL)updateGameInDatabase:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo valueList:(NSArray *)valueList;
+(BOOL)updateEntityInDatabase:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo valueList:(NSArray *)valueList entityName:(NSString *)entityName;
+(void)setUserDefaultValue:(NSString *)value forKey:(NSString *)key;
+(NSString *)getUserDefaultValue:(NSString *)key;
+(UIImage *)plotStatsChart:(NSManagedObjectContext *)mOC predicate:(NSPredicate *)predicate displayBySession:(BOOL)displayBySession;
+(void)drawLine:(CGContextRef)c startX:(int)startX startY:(int)startY endX:(int)endX endY:(int)endY;
+(NSDate *)getFirstDayOfMonth:(NSDate *)thisDay;
+(NSPredicate *)getPredicateForFilter:(NSArray *)formDataArray mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum;
+(void)showAlertPopup:(NSString *)title message:(NSString *)message;
+(void)showAlertPopupWithDelegate:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+(void)showConfirmationPopup:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;
+(void)showAcceptDeclinePopup:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+(void)showTwoButtonPopupWithTitle:(NSString *)title message:(NSString *)message button1:(NSString *)button1 button2:(NSString *)button2 delegate:(id)delegate;
+(void)displayTimeFrameLabel:(UILabel *)label mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum timeFrame:(NSString *)timeFrame;
+(NSArray *)getContentsOfFlatFile:(NSString *)filename;
//+(void)executeThreadedJob:(NSString *)class:(SEL)aSelector:(UIActivityIndicatorView *)activityIndicator;
+(void)updateNewvalueIfNeeded:(NSString *)value type:(NSString *)type mOC:(NSManagedObjectContext *)mOC;
+(BOOL)limitTextViewLength:(UITextView *)textViewLocal currentText:(NSString *)currentText string:(NSString *)string limit:(int)limit saveButton:(UIBarButtonItem *)saveButton resignOnReturn:(BOOL)resignOnReturn;
+(BOOL)limitTextFieldLength:(UITextField *)textViewLocal currentText:(NSString *)currentText string:(NSString *)string limit:(int)limit saveButton:(UIBarButtonItem *)saveButton resignOnReturn:(BOOL)resignOnReturn;
+(void)SetButtonAttributes:(UIButton *)button yearStr:(NSString *)yearStr enabled:(BOOL)enabled;
+(void)resetTheYearSegmentBar:(UITableView *)tableView displayYear:(int)displayYear MoC:(NSManagedObjectContext *)MoC leftButton:(UIButton *)leftButton rightButton:(UIButton *)rightButton displayYearLabel:(UILabel *)displayYearLabel;
+(NSString *)labelForYearValue:(int)yearValue;
+(NSString *)labelForGameSegment:(int)segmentIndex;
+(NSString *)getLast90Days:(NSManagedObjectContext *)mOC;
+(int)selectedSegmentForGameType:(NSString *)gameType;
+(NSManagedObject *)insertRecordIntoEntity:(NSManagedObjectContext *)mOC EntityName:(NSString *)EntityName valueList:(NSArray *)valueList;
+(NSString *)getLastestStatsForFriend:(NSManagedObjectContext *)MoC;
+(NSString *)getLast5GamesForFriend:(NSManagedObjectContext *)MoC;
+(UITableViewCell *)getGameCell:(NSManagedObject *)mo CellIdentifier:(NSString *)CellIdentifier tableView:(UITableView *)tableView  evenFlg:(BOOL)evenFlg;
+(int)getSegmentValueForSegment:(int)segment currentValue:(NSString *)currentValue startGameScreen:(BOOL)startGameScreen;
+(void)initializeSegmentBar:(UISegmentedControl *)segmentBar defaultValue:(NSString *)defaultValue;
+(void)insertFriendGames:(NSMutableArray *)components friend_id:(int)friend_id mOC:(NSManagedObjectContext *)mOC;
+(void)updateOrInsertThisFriend:(NSManagedObjectContext *)mOC line:(NSString *)line;
+(void)updateOrInsertThisMessage:(NSManagedObjectContext *)mOC line:(NSString *)line;
+(BOOL)syncDataWithServer:(NSManagedObjectContext *)mOC delegate:(id)delegate refreshDateLabel:(UILabel *)refreshDateLabel;
+(NSString *)predicateExt:(NSString *)value allValue:(NSString *)allValue field:(NSString *)field typeValue:(NSString *)typeValue mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum;
+(NSString *)formatForDataBase:(NSString *)str;
+(NSString *)getDayTimeFromDate:(NSDate *)localDate;
+(float)getMoneyValueFromText:(NSString *)money;
+(UIImage *)graphGoalsChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(NSString *)getGamesTextFromInt:(int)numGames;
+(CLLocation *)getCurrentLocation;
+(NSString *)getLatitudeFromLocation:(CLLocation *)currentLocation decimalPlaces:(int)decimalPlaces;
+(NSString *)getLongitudeFromLocation:(CLLocation *)currentLocation decimalPlaces:(int)decimalPlaces;
+(float)getDistanceFromTarget:(float)fromLatitude fromLong:(float)fromLongitude toLat:(float)toLatitude toLong:(float)toLongitude;
+(NSString *)getCurrentLocationFromCoreData:(float)fromLatitude long:(float)fromLongitude moc:(NSManagedObjectContext *)managedObjectContext;
+(NSString *)getDefaultLocation:(float)fromLatitude long:(float)fromLongitude moc:(NSManagedObjectContext *)managedObjectContext;
+(NSDate *)getDateInCorrectFormat:(NSString *)istartTime;
+ (UIImage *)imageWithImage:(UIImage *)image newSize:(CGSize)newSize;
+(NSString *)getPicPath:(int)user_id;
+(NSArray *)getStateArray;
+(NSArray *)getCountryArray;
+ (NSString *)formatTelNumberForCalling:(NSString *)phoneNumber;
+(NSString *)formatFieldForWebService:(NSString *)field;
+(NSString *)getDefaultDBLocation:(float)lat lng:(float)lng;
+(void)updateMoneyFloatLabel:(UILabel *)localLabel money:(float)money;
+(void)updateMoneyLabel:(UILabel *)localLabel money:(double)money;
+(int)getPlayerType:(int)amountRisked winnings:(int)winnings;
+(NSString *)getPlayerTypelabel:(int)amountRisked winnings:(int)winnings;
+(UIImage *)getPlayerTypeImage:(int)amountRisked winnings:(int)winnings;
+(void)setFontColorForSegment:(UISegmentedControl *)segment values:(NSArray *)values;
+ (UIView *)getViewForHeaderWithText:(NSString *)headerText;
+(NSString *)convertImgToBase64String:(UIImage *)img height:(int)height;
+(NSString *)convertDataToBase64String:(NSData *)data height:(int)height;
+(NSData *)convertBase64StringToData:(NSString *)imgString;
+(UIImage *)convertBase64StringToImage:(NSString *)imgString;
+(void)updateYourOwnFriendRecord:(NSManagedObjectContext *)MoC list:(NSMutableArray *)list;
+(NSString *)getMoneySymbol;
+(NSArray *)moneySymbols;
+(UIImage *)graphDaysChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(UIImage *)graphDaytimeChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(ChipStackObj *)plotGameChipsChart:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo predicate:(NSPredicate *)predicate displayBySession:(BOOL)displayBySession;
+(void)createChipTimeStamp:(NSManagedObjectContext *)managedObjectContext mo:(NSManagedObject *)mo timeStamp:(NSDate *)timeStamp amount:(int)amount rebuyFlg:(BOOL)rebuyFlg;
+(void)showActionSheet:(id)delegate view:(UIView *)view title:(NSString *)title buttons:(NSArray *)buttons;
+(NSString *)numberWithSuffix:(int)number;
+(int)synvLiveUpdateInfo:(NSManagedObjectContext *)MoC;
+(void)doLiveUpdate:(NSManagedObjectContext *)MoC;
+(UIImage *)graphYearlyChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(NSString *)displayMoney:(NSManagedObject *)mo column:(NSString *)column;
+(NSString *)convertTextToMoneyString:(NSString *)amount;
+(NSString *)convertNumberToMoneyString:(float)money;
+(int)updateFriendData:(NSString *)responseStr MoC:(NSManagedObjectContext *)MoC;
+(BOOL)shouldSyncGameResultsWithServer:(NSManagedObjectContext *)moc;
+(int)updateFriendRecords:(NSManagedObjectContext *)mOC responseStr:(NSString *)responseStr delegate:(id)delegate refreshDateLabel:(UILabel *)refreshDateLabel;
+(int)generateUniqueId;
+(NSString *)getBestLocation:(CLLocation *)currentLocation MoC:(NSManagedObjectContext *)managedObjectContext;
+(NSString *)checkLocation1:(CLLocation *)currentLocation moc:(NSManagedObjectContext *)managedObjectContext;
+(NSString *)checkLocation2:(CLLocation *)currentLocation moc:(NSManagedObjectContext *)managedObjectContext;
+(BOOL)uploadUniverseStats:(NSManagedObjectContext *)mOC;
+(NSString *)pullGameString:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo;
+(void)updateBankroll:(int)winnings bankrollName:(NSString *)bankrollName MOC:(NSManagedObjectContext *)MOC;
+(int)countFriendsPlaying;
+(void)showAlertPopupWithDelegateBG:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+(NSString *)getFriendsPlayingData;
-(void) setReturningValue:(NSString *)value;
+(int)getMinutesPlayedUsingStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime andBreakMin:(int)breakMinutes;
+(NSString *)getHoursPlayedUsingStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime andBreakMin:(int)breakMinutes;
+(int)calculatePprAmountRisked:(int)amountRisked netIncome:(int)netIncome;
+(void)setBankSegment:(UISegmentedControl *)segment;
+(void)bankSegmentChangedTo:(int)number;
+(void)checkBankrollsForSegment:(UISegmentedControl *)segment moc:(NSManagedObjectContext *)moc;
+(void)addColorToButton:(UIButton *)button color:(UIColor *)color;
+ (UIImage *) imageFromColor:(UIColor *)color;
+(UIBarButtonItem *)navigationButtonWithTitle:(NSString *)title selector:(SEL)selector target:(id)target;
+(int)getNewPlayerType:(int)amountRisked winnings:(int)winnings;
+(int)updateGamesOnDevice:(NSManagedObjectContext *)context;
+(void)updateGamesOnServer:(NSManagedObjectContext *)context;
+(void)makeSegment:(UISegmentedControl *)segment color:(UIColor *)color;
+(void)populateSegmentBar:(UISegmentedControl *)segmentBar mOC:(NSManagedObjectContext *)mOC;
+(void)ptpLocationAuthorizedCheck:(CLAuthorizationStatus)status;
+(NSString *)smallLabelForMoney:(float)money totalMoneyRange:(float)totalMoneyRange;
+(float)chartHeightForSize:(float)height;
+(BOOL)isOkToProceed:(NSManagedObjectContext *)context delegate:(id)delegate;

@end
