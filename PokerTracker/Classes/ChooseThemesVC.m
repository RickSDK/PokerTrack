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
#import "ThemeCell.h"

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
	ThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[ThemeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.primaryColorView.backgroundColor=[UIColor clearColor];
	cell.bgColorView.backgroundColor=[UIColor clearColor];
	cell.navBarColorView.backgroundColor=[UIColor clearColor];
	
	if(self.level==1) {
		ThemeColorObj *obj = [self.mainArray objectAtIndex:indexPath.row];
		cell = [ThemeCell cellForRowWithObj:obj cell:cell];
	} else {
		cell.textLabel.text=[self.mainArray objectAtIndex:indexPath.row];
		cell.backgroundColor = [ProjectFunctions primaryButtonColor];
		cell.textLabel.textColor = [ProjectFunctions segmentThemeColor];
	}
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;

	if([ProjectFunctions themeTypeNumber]==1) {
		if(self.level==0 && [ProjectFunctions themeGroupNumber]==indexPath.row)
			cell.accessoryType= UITableViewCellAccessoryCheckmark;
		
		if(self.level==1 && self.group==[ProjectFunctions themeGroupNumber] && [ProjectFunctions themeCategoryNumber]==indexPath.row)
			cell.accessoryType= UITableViewCellAccessoryCheckmark;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.level++;
	if(self.level==1)
		self.group=(int)indexPath.row;
	if(self.level==2)
		self.category=(int)indexPath.row;
	
	if(self.level>=2) {
		[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.group] forKey:@"themeGroupNumber"];
		[ProjectFunctions setUserDefaultValue:[NSString stringWithFormat:@"%d", self.category] forKey:@"themeCategoryNumber"];
		[(EditThemeVC *)self.callBackViewController setTypeToTheme];
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	
	[self.mainArray removeAllObjects];
	NSArray *items = [ThemeColorObj themesOfGroup:self.group];
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
