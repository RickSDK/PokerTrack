//
//  ChooseThemesVC.m
//  PokerTracker
//
//  Created by Rick Medved on 8/16/17.
//
//

#import "ChooseThemesVC.h"
#import "ThemeColorObj.h"
#import "EditThemeVC.h"

@interface ChooseThemesVC ()

@end

@implementation ChooseThemesVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Choose a Theme"];
	self.topButton.enabled=NO;
	[self populateMainList];
}

-(void)populateMainList {
	[self.mainArray removeAllObjects];
	self.group=0;
	self.level=0;
	self.category=0;
	NSArray *items = [ThemeColorObj mainMenuList];
	for(NSString *item in items)
		[self.mainArray addObject:item];
	[self.mainTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [self cellId:indexPath];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	if([ThemeColorObj showThemesForGroup:self.group level:self.level+1]) {
		ThemeColorObj *obj = [self.mainArray objectAtIndex:indexPath.row];
		cell.textLabel.text=obj.name;
		cell.backgroundColor = obj.themeBGColor;
		cell.textLabel.textColor = obj.primaryColor;
	} else {
		cell.textLabel.text=[self.mainArray objectAtIndex:indexPath.row];
		cell.backgroundColor = [ProjectFunctions primaryButtonColor];
		cell.textLabel.textColor = [ProjectFunctions segmentThemeColor];
	}
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.level++;
	if(self.level==1)
		self.group=(int)indexPath.row;
	if(self.level==2)
		self.category=(int)indexPath.row;
	if([ThemeColorObj showThemesForGroup:self.group level:self.level]) {
		[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.group] forKey:@"themeGroupNumber"];
		[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.category] forKey:@"themeCategoryNumber"];
		[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", (int)indexPath.row] forKey:@"themeListItemNumber"];
		[(EditThemeVC *)self.callBackViewController setTypeToTheme];
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	
	[self.mainArray removeAllObjects];
	NSArray *items = [ThemeColorObj subMenuListForGroup:self.group level:self.level category:self.category];
	for(NSString *item in items)
		[self.mainArray addObject:item];
	[self.mainTableView reloadData];
	self.topButton.enabled=YES;
}

- (IBAction) topButtonPressed: (UIButton *) button {
	self.topButton.enabled=NO;
	[self populateMainList];
}

- (IBAction) restoreButtonPressed: (UIButton *) button {
	[(EditThemeVC *)self.callBackViewController resetPressed];
	[self.navigationController popViewControllerAnimated:YES];
}



@end
