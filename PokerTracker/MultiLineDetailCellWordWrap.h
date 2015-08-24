//
//  MultiLineDetailCellWordWrap.h
//
//
//  Word Wrapping is NOT done for the title.  It's done for the data in the fieldTextArray only.

#import <UIKit/UIKit.h>
#import "MultiLineObj.h"


@interface MultiLineDetailCellWordWrap : UITableViewCell {

	NSString *mainTitle;		//set to nil if don't want the row displaying main title and alternate title
	NSString *alternateTitle;
	
	NSArray *titleTextArray;
	NSArray *fieldTextArray;
	NSArray *fieldColorArray;
	UIColor *labelColor;

@private
	UILabel *mainTitleLabel;
	UILabel *alternateTitleLabel;	
	
	float labelWidthProportion;
	NSInteger numberOfRows;
	NSMutableArray *titleLabelArray;
	NSMutableArray *fieldLabelArray;
	NSMutableArray *gridViewArray;	
}

@property (nonatomic, strong) NSString *mainTitle;
@property (nonatomic, strong) NSString *alternateTitle;

@property (nonatomic, strong) NSArray *titleTextArray;
@property (nonatomic, strong) NSArray *fieldTextArray;
@property (nonatomic, strong) NSArray *fieldColorArray;
@property (nonatomic, strong) UIColor *labelColor;

+ (CGFloat)cellHeightForData:(NSArray *)dataArray tableView:(UITableView *)tableView labelWidthProportion:(float)labelWidthProportion;
+ (CGFloat)cellHeightWithNoMainTitleForData:(NSArray *)dataArray tableView:(UITableView *)tableView labelWidthProportion:(float)labelWidthProportion;
+ (CGFloat)cellHeightForMultiCellData:(NSArray *)dataArray
				   tableView:(UITableView *)tableView
				 labelWidthProportion:(float)labelWidthProportion;
+(NSMutableArray *)arrayOfType:(int)type objList:(NSArray *)objList;
+(MultiLineObj *)multiObjectWithName:(NSString *)name value:(NSString *)value color:(UIColor *)color;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
		   withRows:(NSInteger)rows labelProportion:(CGFloat)labelProportion;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withRows:(NSInteger)rows;

@end
