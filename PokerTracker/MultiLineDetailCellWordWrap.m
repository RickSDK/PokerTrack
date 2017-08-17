//
//  MultiLineDetailCellWordWrap.m
//
//

#import "MultiLineDetailCellWordWrap.h"
#import "UIColor+ATTColor.h"
#import "ProjectFunctions.h"

static NSInteger FONT_SIZE			= 14;
static NSInteger COLUMN_SEP			= 6;
static CGFloat LABEL_PROPORTION		= 0.4;
static NSInteger Y_INSET			= 5;
static NSInteger X_INSET			= 5;


@implementation MultiLineDetailCellWordWrap

@synthesize titleTextArray, fieldTextArray, fieldColorArray, leftImage;
@synthesize mainTitle, alternateTitle, labelColor;

//dataArray is the data normally passed into the fieldTextArray.  This function assumes wrapping is not needed on the title.

+ (CGFloat)cellHeightForData:(NSArray *)dataArray 
				   tableView:(UITableView *)tableView  
		labelWidthProportion:(float)labelWidthProportion {

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.text = @"dummy";
	int rowHeight = [label.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]].height;
	
	 //add rowHeight for the maintitle
	return ([MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:dataArray
															   tableView:tableView
													labelWidthProportion:labelWidthProportion] + rowHeight);
}

+ (CGFloat)cellHeightForMultiCellData:(NSArray *)dataArray
				   tableView:(UITableView *)tableView
		labelWidthProportion:(float)labelWidthProportion {

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.text = @"dummy";
	int rowHeight = [label.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]].height;

	NSArray *data = [MultiLineDetailCellWordWrap arrayOfType:1 objList:dataArray];
	return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:data
													tableView:tableView
													labelWidthProportion:labelWidthProportion] + rowHeight;
}

+(NSMutableArray *)arrayOfType:(int)type objList:(NSArray *)objList
{
	NSMutableArray *list = [[NSMutableArray alloc] init];
	for(MultiLineObj *multiLineObj in objList) {
		if(type==0)
			[list addObject:multiLineObj.name];
		if(type==1)
			[list addObject:multiLineObj.value];
		if(type==2)
			[list addObject:multiLineObj.color];
	}
	return list;
}

+(CGFloat)heightForMultiCellObj:(MultiCellObj *)obj tableView:(UITableView *)tableView {
	return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:obj.values
															   tableView:tableView
													labelWidthProportion:obj.labelPercent]+20;
}

+ (UITableViewCell *)multiCellForID:(NSString *)cellIdentifier obj:(MultiCellObj *)obj tableView:(UITableView *)tableView {
	MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:obj.titles.count labelProportion:obj.labelPercent];

	cell.mainTitle = obj.mainTitle;
	cell.alternateTitle = obj.altTitle;
	cell.titleTextArray = obj.titles;
	cell.fieldTextArray = obj.values;
	cell.fieldColorArray = obj.colors;
	
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

+(MultiLineObj *)multiObjectWithName:(NSString *)name value:(NSString *)value color:(UIColor *)color
{
	MultiLineObj *multiLineObj = [[MultiLineObj alloc] init];
	multiLineObj.name = (name.length>0)?name:@"unknown";
	multiLineObj.value = (value.length>0)?value:@"-";
	multiLineObj.color = color;
	return multiLineObj;
}

+ (CGFloat)cellHeightWithNoMainTitleForData:(NSArray *)dataArray 
								  tableView:(UITableView *)tableView 
					   labelWidthProportion:(float)labelWidthProportion {
    // Start with a rect that is inset from the content view.
	
	int width = tableView.frame.size.width;
    
	if (tableView.style == UITableViewStyleGrouped)
		width -= (width*.02);
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.text = @"dummy";
	
	int rowHeight = [label.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]].height;
    CGRect baseRect =  CGRectInset(CGRectMake(0,0, width, rowHeight), X_INSET, Y_INSET);
	int leftSection = trunc(baseRect.size.width * labelWidthProportion);
	
	// detail rows
	int rows = (int)[dataArray count];
	CGRect rect = baseRect;
	rect.origin.x += leftSection+COLUMN_SEP;
	rect.size.width = baseRect.size.width - (leftSection+COLUMN_SEP);								   
	CGSize size;
	for (int i=0; i<rows; i++) {
		if (i != 0) 
			rect.origin.y += label.frame.size.height;
		rect.size.height = 20000.0f; //large #
		label.text = [dataArray objectAtIndex:i];
		size = [label.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:rect.size lineBreakMode:NSLineBreakByWordWrapping];
		rect.size.height = MAX(size.height,rowHeight);
		label.frame = rect;
	}
    
    
	return rect.origin.y + rect.size.height + Y_INSET;	
}


- (void)setMainTitle:(NSString *)newTitle {
	if (mainTitle != newTitle) {
		mainTitle = newTitle;
	}
	mainTitleLabel.text = mainTitle;
}

- (void)setAlternateTitle:(NSString *)newTitle {
	if (alternateTitle != newTitle) {
		alternateTitle = newTitle;
	}
	alternateTitleLabel.text = alternateTitle;
}

- (void)setTitleTextArray:(NSArray *)newArray {
	if (titleTextArray != newArray) {
		titleTextArray = newArray;
	}
	int rows = (int)numberOfRows;
	for (int i=0; i<rows; i++) {
		UILabel *label = [titleLabelArray objectAtIndex:i];
		label.text = [titleTextArray objectAtIndex:i];
	}
}

- (void)setFieldTextArray:(NSArray *)newArray {
	if (fieldTextArray != newArray) {
		fieldTextArray = newArray;
	}
//	int rows = numberOfRows;
	int rows = (int)[fieldTextArray count];
	if(fieldLabelArray.count<rows)
		rows = (int)fieldLabelArray.count;
	for (int i=0; i<rows; i++) {
		UILabel *label = [fieldLabelArray objectAtIndex:i];
		label.text = [fieldTextArray objectAtIndex:i];
	}
}

- (void)setFieldColorArray:(NSArray *)newArray {
	if (fieldColorArray != newArray) {
		fieldColorArray = newArray;
	}
	int rows = (int)numberOfRows;
	for (int i=0; i<rows; i++) {
		UILabel *label = [fieldLabelArray objectAtIndex:i];
        if([fieldColorArray count]>i)
            label.textColor = [fieldColorArray objectAtIndex:i];
	}
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
		   withRows:(NSInteger)rows  labelProportion:(CGFloat)labelProportion {
	numberOfRows = rows;
	labelWidthProportion = labelProportion;
	return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withRows:(NSInteger)rows {
	numberOfRows = rows;
	labelWidthProportion = LABEL_PROPORTION;
	return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        // Initialize the labels, their fonts, colors, alignment, and background color.
        // Add the labels to the content view of the cell.
		mainTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		mainTitleLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
//		mainTitleLabel.textColor = [UIColor blackColor]; //<-- note, set below
		mainTitleLabel.textAlignment = NSTextAlignmentLeft;
		mainTitleLabel.backgroundColor = [UIColor clearColor];
		//mainTitleLabel.backgroundColor = [UIColor yellowColor];
		[self.contentView addSubview:mainTitleLabel];
		
		alternateTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		alternateTitleLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
		alternateTitleLabel.textColor = [ProjectFunctions themeBGColor];
		alternateTitleLabel.textAlignment = NSTextAlignmentRight;
		alternateTitleLabel.backgroundColor = [UIColor clearColor];
		//alternateTitleLabel.backgroundColor = [UIColor yellowColor];
		[self.contentView addSubview:alternateTitleLabel];		
		
		titleLabelArray = [[NSMutableArray alloc] init];
		fieldLabelArray = [[NSMutableArray alloc] init];
		NSMutableArray *fieldColors = [[NSMutableArray alloc] init];
		gridViewArray = [[NSMutableArray alloc] init];
		
		UIColor *evenRowColor = [UIColor ATTCellRowShading];
		evenRowColor = [UIColor colorWithWhite:1 alpha:1];
		UIColor *oddRowColor = [UIColor colorWithWhite:.96 alpha:1];
//		oddRowColor = [ProjectFunctions primaryButtonColor];

		UILabel *label;
		UIView *grid;
		int rows = (int)numberOfRows;
		for (int i=0; i<rows; i++) {
			// Add grid first so it is at the back;
			grid = [[UIView alloc] initWithFrame:CGRectZero];
			grid.backgroundColor = (i % 2 == 0 ? evenRowColor : oddRowColor);
			[gridViewArray addObject:grid];
			[self.contentView addSubview:grid];
			
			// the title
			label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.font = [UIFont systemFontOfSize:FONT_SIZE];
			label.textColor = [UIColor darkGrayColor];		// default dark gray color
			label.textAlignment = NSTextAlignmentRight;
			label.backgroundColor = [UIColor clearColor];
//			[label setLineBreakMode:UILineBreakModeWordWrap];
//			[label setNumberOfLines:0];		
			
			[titleLabelArray addObject:label];
			[self.contentView addSubview:label];
			
			// the value
			label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.font = [UIFont systemFontOfSize:FONT_SIZE];
			label.textColor = [UIColor blackColor];			// default black color
			label.backgroundColor = [UIColor clearColor];
			[label setLineBreakMode:NSLineBreakByWordWrapping];
			[label setNumberOfLines:0];

			[fieldLabelArray addObject:label];
			[self.contentView addSubview:label];
			[fieldColors addObject:[UIColor blackColor]];
		}
		self.leftImage = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:self.leftImage];

		self.fieldColorArray = fieldColors;
		self.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
	// If selection style is 'None' it means we don't want the UI to simulate not being selectable so
	// don't change text color.
	
    // Configure the view for the selected state
    if (selected && self.selectionStyle != UITableViewCellSelectionStyleNone) {
		[mainTitleLabel setTextColor:[UIColor whiteColor]];		
		int rows = (int)numberOfRows;
		for (int i=0; i<rows; i++) {
			[[titleLabelArray objectAtIndex:i] setTextColor:[UIColor whiteColor]];
			[[fieldLabelArray objectAtIndex:i] setTextColor:[UIColor whiteColor]];
		}
    } else {
		[mainTitleLabel setTextColor:[ProjectFunctions segmentThemeColor]];
		int rows = (int)numberOfRows;
		for (int i=0; i<rows; i++) {
			[[titleLabelArray objectAtIndex:i] setTextColor:(labelColor ? labelColor : [UIColor colorWithWhite:.4 alpha:1])];
            if([fieldColorArray count]>i)
                [[fieldLabelArray objectAtIndex:i] setTextColor:[fieldColorArray objectAtIndex:i]];
		}
    }
}


- (void)layoutSubviews {
	
    [super layoutSubviews];

	self.leftImage.frame = CGRectMake(0, 0, self.frame.size.height*.75, self.frame.size.height);

    // Start with a rect that is inset from the content view.
    CGRect baseRect = CGRectInset(self.contentView.bounds, X_INSET, Y_INSET);
	int leftSection = trunc(baseRect.size.width * labelWidthProportion);
	
	int rows = (int)numberOfRows;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.text = @"dummy";
	int rowHeight = [label.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]].height;
	
	baseRect.size.height = rowHeight;

	if (mainTitle) {
		CGRect mainRect = baseRect;
		mainTitleLabel.frame = mainRect;
		mainRect.size.width -= 10;
		alternateTitleLabel.frame = mainRect;
		baseRect.origin.y += rowHeight;	  //shift down for rest of rows	
	}
	
	CGRect gridRect = baseRect;
	CGRect titleRect = baseRect;
	titleRect.size.width = leftSection;	
	CGRect fieldRect = baseRect;
	fieldRect.origin.x += leftSection+COLUMN_SEP;
	fieldRect.size.width = baseRect.size.width - (leftSection+COLUMN_SEP);
	CGSize size;
	for (int i=0; i<rows; i++) {
		if (i != 0) {
			fieldRect.origin.y += label.frame.size.height;	// add height of previous line
			gridRect.origin.y = titleRect.origin.y = fieldRect.origin.y;
		}
		if(titleLabelArray.count>i) {
			label = [titleLabelArray objectAtIndex:i];
			if(label) {
				label.frame = titleRect;
				
				fieldRect.size.height = 20000.0f; //large #
				label = [fieldLabelArray objectAtIndex:i];
				size = [label.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:fieldRect.size lineBreakMode:NSLineBreakByWordWrapping];
				fieldRect.size.height = MAX(size.height,rowHeight);
				label.frame = fieldRect;
			}
		}
		
		gridRect.size.height = fieldRect.size.height;
		((UIView *)[gridViewArray objectAtIndex:i]).frame = gridRect;

	}
	
}




@end
