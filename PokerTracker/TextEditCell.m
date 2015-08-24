//
//  TextEditCell.m
//  BASE
//
//

#import "TextEditCell.h"

#define kCellLeftOffset			8.0

#define kTextFieldHeight		30.0
#define kTextFieldWidth			110.0	// 95.0


@implementation TextEditCell

@synthesize textField, labelProportion, fixedTextFieldWidth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];	// label is 17, system is 14
		self.textLabel.textAlignment = UITextAlignmentLeft;
		
		// turn off selection use
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Create and configure text field
		CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
		textField = [[UITextField alloc] initWithFrame:frame];
		textField.borderStyle = UITextBorderStyleRoundedRect;
		textField.textColor = [UIColor blackColor];
		textField.font = [UIFont systemFontOfSize:17.0];
		textField.placeholder = @"starts with";
		textField.backgroundColor = [UIColor whiteColor];
//		textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.returnKeyType = UIReturnKeyDone;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right	
		[self.contentView addSubview:textField];
// calling this in 3.0 causes selection highlighting to have square corners even though table style is Grouped
//		[self layoutSubviews];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{	
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	CGRect rect = textField.frame;
	if (labelProportion > 0) {
		rect.size.width = round (contentRect.size.width * (1 - labelProportion));
		textField.frame = rect;
	}
	else if (fixedTextFieldWidth > 0) {
		rect.size.width = fixedTextFieldWidth;
		rect.origin.x = contentRect.size.width - fixedTextFieldWidth + contentRect.origin.x;
		textField.frame = rect;
	}
	
	CGRect uiFrame = CGRectMake(contentRect.size.width - textField.frame.size.width - kCellLeftOffset,
								round((contentRect.size.height - textField.frame.size.height) / 2.0),
								textField.frame.size.width,
								textField.frame.size.height);
	textField.frame = uiFrame;
	CGRect labelRect = self.textLabel.frame;
	labelRect.size.width = uiFrame.origin.x - labelRect.origin.x; 
	self.textLabel.frame = labelRect;  //have to resize label as well else cursor on textfield is off when using clear 'x'
	[self.contentView bringSubviewToFront:textField];
}



@end
