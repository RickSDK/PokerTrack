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
#import "GameStatObj.h"


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
#define kLOG 0
#define kPRODMode 1
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
+(int)getNowYear;
+(NSString *)getProjectVersion;
+(NSString *)getProjectDisplayVersion;
+(float)projectVersionNumber;
+(BOOL)useThreads;
+(NSArray *)getFieldListForVersion:(NSString *)version type:(NSString *)type;
+(NSArray *)sortArray:(NSMutableArray *)list;
+(NSArray *)sortArrayDescending:(NSArray *)list;
+(NSString *)getWinLossStreakString:(int)streak;
+(NSString *)getYearString:(int)year;
+(NSPredicate *)predicateForBasic:(NSString *)basicPred field:(NSString *)field value:(NSString *)value;
+(NSString *)getBasicPredicateString:(int)year type:(NSString *)Type;
+(NSString *)getPredicateString:(NSArray *)formDataArray mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum;
+(NSString *)convertIntToMoneyString:(double)money;
+(NSArray *)getArrayForSegment:(int)segment;
+(void)displayLoginMessage;
+(NSString *)hourlyStringFromProfit:(double)profit hours:(float)hours;
+(NSString *)pprStringFromProfit:(double)profit risked:(double)risked;
+(NSArray *)getColumnListForEntity:(NSString *)entityName type:(NSString *)type;
+(BOOL)updateGameInDatabase:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo valueList:(NSArray *)valueList;
+(UIImage *)playerImageOfType:(int)type;
+(BOOL)updateEntityInDatabase:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo valueList:(NSArray *)valueList entityName:(NSString *)entityName;
+(BOOL)trackChipsSwitchValue;
+(void)newButtonLook:(UIButton *)button mode:(int)mode;
+(NSString *)playerTypeFromLlooseNum:(int)looseNum agressiveNum:(int)agressiveNum ;
+(void)setUserDefaultValue:(NSString *)value forKey:(NSString *)key;
+(NSString *)localizedTitle:(NSString *)title;
+(NSString *)getUserDefaultValue:(NSString *)key;
+(UIImage *)plotStatsChart:(NSManagedObjectContext *)mOC predicate:(NSPredicate *)predicate displayBySession:(BOOL)displayBySession;
+(void)drawLine:(CGContextRef)c startX:(int)startX startY:(int)startY endX:(int)endX endY:(int)endY;
+(NSDate *)getFirstDayOfMonth:(NSDate *)thisDay;
+(NSString *)getWeekDayFromDate:(NSDate *)date;
+(NSPredicate *)predicateForGameSegment:(UISegmentedControl *)segment;
+(NSPredicate *)getPredicateForFilter:(NSArray *)formDataArray mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum;
+(void)showAlertPopup:(NSString *)title message:(NSString *)message;
+(void)showAlertPopupWithDelegate:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+(void)showConfirmationPopup:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;
+(void)showAcceptDeclinePopup:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+(void)showTwoButtonPopupWithTitle:(NSString *)title message:(NSString *)message button1:(NSString *)button1 button2:(NSString *)button2 delegate:(id)delegate;
+(NSArray *)getValuesForField:(NSString *)field context:(NSManagedObjectContext *)context year:(int)year type:(NSString *)type;
+(void)displayTimeFrameLabel:(UILabel *)label mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum timeFrame:(NSString *)timeFrame;
+(NSArray *)getContentsOfFlatFile:(NSString *)filename;
+(NSString *)getBasicPredicateStringNoBankroll:(int)year type:(NSString *)Type;
+(UIImage *)getPtpPlayerTypeImage:(double)amountRisked winnings:(double)winnings iconGroupNumber:(int)iconGroupNumber;
+(NSString *)playerTypeLongFromLooseNum:(int)looseNum agressiveNum:(int)agressiveNum;
//+(void)executeThreadedJob:(NSString *)class:(SEL)aSelector:(UIActivityIndicatorView *)activityIndicator;
+(void)updateNewvalueIfNeeded:(NSString *)value type:(NSString *)type mOC:(NSManagedObjectContext *)mOC;
+(BOOL)limitTextViewLength:(UITextView *)textViewLocal currentText:(NSString *)currentText string:(NSString *)string limit:(int)limit saveButton:(UIBarButtonItem *)saveButton resignOnReturn:(BOOL)resignOnReturn;
+(BOOL)limitTextFieldLength:(UITextField *)textViewLocal currentText:(NSString *)currentText string:(NSString *)string limit:(int)limit saveButton:(UIBarButtonItem *)saveButton resignOnReturn:(BOOL)resignOnReturn;
+(void)SetButtonAttributes:(UIButton *)button yearStr:(NSString *)yearStr enabled:(BOOL)enabled;
+(void)resetTheYearSegmentBar:(UITableView *)tableView displayYear:(int)displayYear MoC:(NSManagedObjectContext *)MoC leftButton:(UIButton *)leftButton rightButton:(UIButton *)rightButton displayYearLabel:(UILabel *)displayYearLabel;
+(NSString *)labelForYearValue:(int)yearValue;
+(NSString *)faStringOfType:(int)type;
+(int)findMinAndMaxYear:(NSManagedObjectContext *)context;
+(void)addGradientToView:(UIView *)view;
+(UIColor *)gradientBGColorForWidth:(float)width height:(float)height;
+(NSString *)labelForGameSegment:(int)segmentIndex;
+(NSString *)getMonthFromDate:(NSDate *)date;
+(NSArray *)namesOfAllWeekdays;
+(NSArray *)namesOfAllMonths;
+(NSArray *)namesOfAllDayTimes;
+(UIBarButtonItem *)UIBarButtonItemWithIcon:(NSString *)icon target:(id)target action:(SEL)action;
+(void)scrubDataForObj:(NSManagedObject *)mo context:(NSManagedObjectContext *)context;
+(NSString *)getLast90Days:(NSManagedObjectContext *)mOC;
+(int)selectedSegmentForGameType:(NSString *)gameType;
+(NSManagedObject *)insertRecordIntoEntity:(NSManagedObjectContext *)mOC EntityName:(NSString *)EntityName valueList:(NSArray *)valueList;
+(NSString *)getLastestStatsForFriend:(NSManagedObjectContext *)MoC;
+(NSString *)getLast5GamesForFriend:(NSManagedObjectContext *)MoC;
+(UITableViewCell *)getGameCell:(NSManagedObject *)mo CellIdentifier:(NSString *)CellIdentifier tableView:(UITableView *)tableView  evenFlg:(BOOL)evenFlg;
+(int)getSegmentValueForSegment:(int)segment currentValue:(NSString *)currentValue startGameScreen:(BOOL)startGameScreen;
+(void)initializeSegmentBar:(UISegmentedControl *)segmentBar defaultValue:(NSString *)defaultValue field:(NSString *)field;
+(void)insertFriendGames:(NSMutableArray *)components friend_id:(int)friend_id mOC:(NSManagedObjectContext *)mOC;
+(void)updateOrInsertThisFriend:(NSManagedObjectContext *)mOC line:(NSString *)line;
+(void)updateOrInsertThisMessage:(NSManagedObjectContext *)mOC line:(NSString *)line;
+(BOOL)syncDataWithServer:(NSManagedObjectContext *)mOC delegate:(id)delegate refreshDateLabel:(UILabel *)refreshDateLabel;
+(NSString *)predicateExt:(NSString *)value allValue:(NSString *)allValue field:(NSString *)field typeValue:(NSString *)typeValue mOC:(NSManagedObjectContext *)mOC buttonNum:(int)buttonNum;
+(NSString *)scrubRefData:(NSString *)data context:(NSManagedObjectContext *)context;
+(NSString *)formatForDataBase:(NSString *)str;
+(NSString *)getDayTimeFromDate:(NSDate *)localDate;
+(UIImage *)graphGoalsChart:(NSManagedObjectContext *)mOC displayYear:(int)displayYear chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
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
+(int)getPlayerType:(double)amountRisked winnings:(double)winnings;
+(NSString *)getPlayerTypelabel:(double)amountRisked winnings:(double)winnings;
+(UIImage *)getPlayerTypeImage:(double)amountRisked winnings:(double)winnings;
+(void)setFontColorForSegment:(UISegmentedControl *)segment values:(NSArray *)values;
+ (UIView *)getViewForHeaderWithText:(NSString *)headerText;
+(NSString *)convertImgToBase64String:(UIImage *)img height:(int)height;
+(NSString *)convertDataToBase64String:(NSData *)data height:(int)height;
+(NSData *)convertBase64StringToData:(NSString *)imgString;
+(UIImage *)convertBase64StringToImage:(NSString *)imgString;
+(void)updateYourOwnFriendRecord:(NSManagedObjectContext *)MoC list:(NSMutableArray *)list;
+(NSString *)displayLocalFormatDate:(NSDate *)date showDay:(BOOL)showDay showTime:(BOOL)showTime;
+(NSString *)getMoneySymbol;
+(NSString *)getMoneySymbol2;
+(NSArray *)moneySymbols;
+(UIImage *)graphDaysChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(UIImage *)graphDaytimeChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(ChipStackObj *)plotGameChipsChart:(NSManagedObjectContext *)mOC mo:(NSManagedObject *)mo predicate:(NSPredicate *)predicate displayBySession:(BOOL)displayBySession;
+(void)createChipTimeStamp:(NSManagedObjectContext *)managedObjectContext mo:(NSManagedObject *)mo timeStamp:(NSDate *)timeStamp amount:(double)amount rebuyFlg:(BOOL)rebuyFlg;
+(void)showActionSheet:(id)delegate view:(UIView *)view title:(NSString *)title buttons:(NSArray *)buttons;
+(NSString *)numberWithSuffix:(int)number;
+(int)synvLiveUpdateInfo:(NSManagedObjectContext *)MoC;
+(void)doLiveUpdate:(NSManagedObjectContext *)MoC;
+(UIImage *)graphYearlyChart:(NSManagedObjectContext *)mOC yearStr:(NSString *)yearStr chartNum:(int)chartNum goalFlg:(BOOL)goalFlg;
+(NSString *)displayMoney:(NSManagedObject *)mo column:(NSString *)column;
+(NSString *)convertTextToMoneyString:(NSString *)amount;
+(NSString *)convertNumberToMoneyString:(double)money;
+(NSString *)convertStringToMoneyString:(NSString *)moneyStr;
+(double)convertMoneyStringToDouble:(NSString *)moneyStr;
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
+(int)calculatePprAmountRisked:(double)amountRisked netIncome:(double)netIncome;
+(void)setBankSegment:(UISegmentedControl *)segment;
+(void)bankSegmentChangedTo:(int)number;
+(void)checkBankrollsForSegment:(UISegmentedControl *)segment moc:(NSManagedObjectContext *)moc;
+(void)addColorToButton:(UIButton *)button color:(UIColor *)color;
+ (UIImage *) imageFromColor:(UIColor *)color;
+(UIBarButtonItem *)navigationButtonWithTitle:(NSString *)title selector:(SEL)selector target:(id)target;
+(int)getNewPlayerType:(double)amountRisked winnings:(double)winnings;
+(int)updateGamesOnDevice:(NSManagedObjectContext *)context;
+(void)updateGamesOnServer:(NSManagedObjectContext *)context;
+(void)makeSegment:(UISegmentedControl *)segment color:(UIColor *)color;
+(void)makeSegment:(UISegmentedControl *)segment color:(UIColor *)color size:(float)size;
+(void)populateSegmentBar:(UISegmentedControl *)segmentBar mOC:(NSManagedObjectContext *)mOC;
+(void)ptpLocationAuthorizedCheck:(CLAuthorizationStatus)status;
+(NSString *)smallLabelForMoney:(double)money totalMoneyRange:(double)totalMoneyRange;
+(float)chartHeightForSize:(float)height;
+(UIColor *)colorForProfit:(double)profit;
+(BOOL)isOkToProceed:(NSManagedObjectContext *)context delegate:(id)delegate;
+(NSString *)getNetTrackerMonth;
+(void)tintNavigationBar:(UINavigationBar *)navigationBar;
+(void)makeFAButton:(UIButton *)button type:(int)type size:(float)size;
+(void)makeFAButton2:(UIButton *)button type:(int)type size:(float)size;
+(void)makeFALabel:(UILabel *)label type:(int)type size:(float)size;
+(void)makeFAButton:(UIButton *)button type:(int)type size:(float)size text:(NSString *)text;
+(void)changeToModernThemeForButton:(UIButton *)button mode:(int)mode theme:(int)theme;
+(UIImage *)gradientImageNavbarOfWidth:(float)width;
+(NSString *)scrubFilterValue:(NSString *)value;
+(NSString *)nameOfTheme;
+(UIColor *)colorForPlayerType:(int)type;
+(int)appThemeNumber;
+(int)themeBGNumber;
+(int)segmentColorNumber;
+(int)primaryColorNumber;
+(int)themeTypeNumber;
+(int)themeGroupNumber;
+(int)themeCategoryNumber;
+(UIColor *)grayThemeColor;
+(UIColor *)themeBGColor;
+(NSArray *)bgThemeColors;
+(NSArray *)navBarThemeColors;
+(UIColor *)primaryButtonColor;
+(NSArray *)primaryButtonColors;
+(UIColor *)segmentThemeColor;
+(BOOL)getThemeBGImageFlg;
+(int)getThemeBGImageColor;
+(UIImage *)bgThemeImage;

@end
