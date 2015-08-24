//
//  ForumCreateVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import "ForumCreateVC.h"
#import "ProjectFunctions.h"
#import "WebServicesFunctions.h"

@interface ForumCreateVC ()

@end

@implementation ForumCreateVC
@synthesize postStr, postId, category, postButton;
@synthesize categoryLabel, activityIndicator, actImageView, titleTextField, bodyTextView;


-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return [ProjectFunctions limitTextFieldLength:textFieldlocal currentText:self.titleTextField.text string:string limit:50 saveButton:nil resignOnReturn:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)postMessage
{
	@autoreleasepool {
    
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"category", @"postId", @"title", @"body", nil];
		NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
		NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
    NSString *catStr = [NSString stringWithFormat:@"%d", self.category];
    NSString *postIdStr = [NSString stringWithFormat:@"%d", self.postId];
		NSArray *valueList = [NSArray arrayWithObjects:username, password, catStr, postIdStr, self.titleTextField.text, self.bodyTextView.text, nil];
    
 	NSString *webAddr = @"http://www.appdigity.com/poker/forumSubmitPost.php";
		NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
    NSLog(@"responseStr: %@", responseStr);
    if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
        [ProjectFunctions showAlertPopupWithDelegate:@"Message Posted" message:@"" delegate:self];
    }
 	
		[self.activityIndicator stopAnimating];
    self.actImageView.alpha=0;
    
 	}
}


-(void)replyButtonClicked:(id)sender {
    if([self.titleTextField.text length]==0) {
        [ProjectFunctions showAlertPopup:@"Error" message:@"Enter a title"];
        return;
    }
    if([self.bodyTextView.text length]==0) {
        [ProjectFunctions showAlertPopup:@"Error" message:@"Enter a message body"];
        return;
    }
    [self.titleTextField resignFirstResponder];
    [self.bodyTextView resignFirstResponder];

    self.postButton.enabled=NO;
    [self.activityIndicator startAnimating];
    self.actImageView.alpha=1;
	[self performSelectorInBackground:@selector(postMessage) withObject:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Forum"];
    self.actImageView.alpha=0;
    NSArray *titles = [NSArray arrayWithObjects:@"Announcements", @"General", @"Strategy", @"Bad Beats", nil];
    self.categoryLabel.text = [titles objectAtIndex:self.category];
    
	self.postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(replyButtonClicked:)];
	self.navigationItem.rightBarButtonItem = self.postButton;
    self.postButton.enabled=YES;

    
     if(self.postId>0) {
        NSArray *parts = [self.postStr componentsSeparatedByString:@"|"];
        if([parts count]>3) {
            self.titleTextField.text=[parts objectAtIndex:3];
            self.titleTextField.enabled=NO;
            [self.postButton setTitle:@"Post Reply"];
        }
    }
    
    // Do any additional setup after loading the view from its nib.
}





@end
