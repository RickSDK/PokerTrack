//
//  ForumVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/1/13.
//
//

#import "ForumVC.h"
#import "ForumCategoryVC.h"
#import "ForumPostVC.h"
#import "ForumCreateVC.h"
#import "WebServicesFunctions.h"
#import "ProjectFunctions.h"
#import "ForumCell.h"
#import "ProfileVC.h"
#import "NSDate+ATTDate.h"


@interface ForumVC ()

@end

@implementation ForumVC
@synthesize  managedObjectContext, forumPostings, activityIndicator, mainTableView;


- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitle:@"Forum"];
	[self changeNavToIncludeType:30];
	
	self.forumPostings = [[NSMutableArray alloc] initWithCapacity:4];
	
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAPlus] target:self action:@selector(addButtonPressed:)];
	
	[self refreshPage];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)profilePressed:(id)sender {
	ProfileVC *detailViewController = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)postNewMessage:(int)number {
    if([ProjectFunctions isLiteVersion]) {
        [ProjectFunctions showAlertPopup:NSLocalizedString(@"notice", nil) message:@"Users of Lite version cannot post messages. Please upgrade!"];
        return;
    }
    ForumCreateVC *detailViewController = [[ForumCreateVC alloc] initWithNibName:@"ForumCreateVC" bundle:nil];
    detailViewController.category=number;
    [self.navigationController pushViewController:detailViewController animated:YES];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            ProfileVC *detailViewController = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
            detailViewController.managedObjectContext = managedObjectContext;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
            break;
        case 1: {
            [self postNewMessage:(int)buttonIndex];
        }
            break;
        case 2: {
            [self postNewMessage:(int)buttonIndex];
        }
            break;
        case 3: {
            [self postNewMessage:(int)buttonIndex];
        }
            break;
            
        default:
            break;
    }
}

-(void)addButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Create Post" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Profile" otherButtonTitles:@"General", @"Strategy", @"Bad Beats", nil];
    
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:self.view];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(void)loadForum
{
	@autoreleasepool {
    
        [self.forumPostings removeAllObjects];
		
        NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
	NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
	NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
	NSArray *valueList = [NSArray arrayWithObjects:username, password, nil];
        
 	NSString *webAddr = @"http://www.appdigity.com/poker/forumGetHeadlines.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"responseStr: %@", responseStr);
        if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
            NSArray *parts1 = [responseStr componentsSeparatedByString:@"<br>"];
            if([parts1 count]>1) {
                NSArray *categories = [[parts1 objectAtIndex:1] componentsSeparatedByString:@"<a>"];
                for(NSString *cat in categories) {
                    NSArray *postings = [cat componentsSeparatedByString:@"<b>"];
                    [self.forumPostings addObject:postings];
                }
            }
        }
        [self.forumPostings removeLastObject];
 	
	[self.activityIndicator stopAnimating];
        [self.mainTableView reloadData];
	}
}

-(void)refreshPage {
    [self.activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(loadForum) withObject:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
        cell = [[ForumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
   
    if(indexPath.row==0) {
        cell.repliesLabel.alpha=0;
        cell.repliesNumber.alpha=0;
        cell.bodyLabel.alpha=0;
        cell.userLabel.alpha=0;
        cell.dateLabel.alpha=0;
        NSArray *titles = [NSArray arrayWithObjects:@"Announcements", @"General", @"Strategy", @"Bad Beats", @"Whoa!", nil];
        cell.textLabel.text=[titles objectAtIndex:indexPath.section];
        cell.textLabel.textColor = [ProjectFunctions primaryButtonColor];
        cell.accessoryType= UITableViewCellAccessoryNone;
        cell.backgroundColor=[ProjectFunctions segmentThemeColor];
    } else {
        cell.repliesLabel.alpha=1;
        cell.repliesNumber.alpha=1;
        cell.bodyLabel.alpha=1;
        cell.userLabel.alpha=1;
        cell.dateLabel.alpha=1;
        

        cell.backgroundColor = [ProjectFunctions primaryButtonColor];
        cell.textLabel.textColor = [UIColor blackColor];
        NSString *post = [[self.forumPostings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
        NSArray *parts = [post componentsSeparatedByString:@"|"];
        if([parts count]>9) {
            cell.titleLabel.text=[parts objectAtIndex:3];
            cell.userLabel.text=[parts objectAtIndex:5];
            cell.dateLabel.text=[parts objectAtIndex:7];
            int minutes = [[parts objectAtIndex:6] intValue];
            cell.repliesNumber.text=[parts objectAtIndex:9];
			cell.mainImg.image = nil;

			if(minutes<720)
                cell.dateLabel.text=@"Today";
            cell.bodyLabel.text=[parts objectAtIndex:8];
            if([@"Y" isEqualToString:[parts objectAtIndex:4]])
                cell.mainImg.image = [UIImage imageNamed:@"new.png"];
        }
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.forumPostings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.forumPostings objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0)
        return 40;
    else
        return 44;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0) {
        ForumCategoryVC *detailViewController = [[ForumCategoryVC alloc] initWithNibName:@"ForumCategoryVC" bundle:nil];
        detailViewController.managedObjectContext = self.managedObjectContext;
        detailViewController.category=(int)indexPath.section;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        if(0) {
            ForumCreateVC *detailViewController = [[ForumCreateVC alloc] initWithNibName:@"ForumCreateVC" bundle:nil];
            detailViewController.category=(int)indexPath.section;
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            ForumPostVC *detailViewController = [[ForumPostVC alloc] initWithNibName:@"ForumPostVC" bundle:nil];
            detailViewController.managedObjectContext = self.managedObjectContext;
            detailViewController.category=(int)indexPath.section;
            detailViewController.postStr=[[self.forumPostings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

@end
