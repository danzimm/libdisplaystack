#import "PSViewController.h"
#import "PSSpecifier.h"
#import "UIModalView.h"
#import "UIKeyboard.h"
#import <objc/runtime.h>

@interface PSViewController (iPad)
- (id)navigationController;
- (void)setSpecifier:(PSSpecifier *)spec;
- (void)viewWillDisappear;
- (void)viewWillAppear:(BOOL)animated;
@end

@interface UIKeyboard (iPad)
+ (void)initImplementationNow;
@end


@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

@interface DSApplicationCell : UITableViewCell {
	
}

@end


@implementation DSApplicationCell
- (void)layoutSubviews
{
    [super layoutSubviews];
	
    // Resize icon image
    CGSize size = self.bounds.size;
    self.imageView.frame = CGRectMake(4.0f, 4.0f, size.height - 8.0f, size.height - 8.0f);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end

@interface DSNewPasswordController : PSViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITextField *passField;
	UITextField *passField2;
	int _use;
	UITableView *_tableView;
	UIKeyboard *_keyBoard;
}
- (UIView *)view;
- (void)setNavigationTitle:(NSString *)navigationTitle;

@end

@implementation DSNewPasswordController

- (id)initForContentSize:(CGSize)size
{
	return [self init];
}

- (id)init
{
	if ((self = [super init]) != nil) {
		passField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f,10.0f,[[UIScreen mainScreen] bounds].size.width, 24.0f)];
		passField.placeholder = @"New Password";
		passField.clearButtonMode = UITextFieldViewModeAlways;
		passField.autocorrectionType = UITextAutocorrectionTypeNo;
		passField.secureTextEntry = YES;
		passField.font = [UIFont systemFontOfSize:16.0f];
		passField.backgroundColor = [UIColor clearColor];
		passField.delegate = self;
		passField2 = [[UITextField alloc] initWithFrame:CGRectMake(0.0f,34.0f,[[UIScreen mainScreen] bounds].size.width, 24.0f)];
		passField2.placeholder = @"New Password Again";
		passField2.clearButtonMode = UITextFieldViewModeAlways;
		passField2.autocorrectionType = UITextAutocorrectionTypeNo;
		passField2.secureTextEntry = YES;
		passField2.font = [UIFont systemFontOfSize:16.0f];
		passField2.backgroundColor = [UIColor clearColor];
		passField2.delegate = self;
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];		
		if isWildcat
			[UIKeyboard initImplementationNow];
		else
			_keyBoard = [UIKeyboard automaticKeyboard];
		[_keyBoard orderInWithAnimation:YES];
	}
	return self;
}

- (void) dealloc {
	[_tableView release];
	[super dealloc];
}

- (NSString *) navigationTitle {
	return @"New Password";
}

- (void)setNavigationTitle:(NSString *)navigationTitle
{
	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:navigationTitle];
}

- (id) view
{
	return _tableView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([passField.text isEqualToString:passField2.text]) {
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"] ?: [[NSMutableDictionary alloc] init];
		[prefs setObject:passField.text forKey:@"password"];
		[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist" atomically:YES];
		[prefs release];
		UIModalView *alert = [[UIModalView alloc] initWithTitle:@"New Password" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
		[alert setBodyText:[NSString stringWithFormat:@"You have just set your password to be: %@", passField.text]];
		[alert popupAlertAnimated:YES];
		[alert release];
		if isWildcat {
			[UIKeyboard initImplementationNow];
		} else {
			[_keyBoard orderInWithAnimation:YES];
		}		
		if isWildcat {
			[[self navigationController] popViewControllerAnimated:YES];
		} else {
			[self navigationBarButtonClicked:0];
		}
		return YES;
	}
	return NO;
}	

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (!isWildcat)
		[_keyBoard orderInWithAnimation:YES];
	else
		[UIKeyboard initImplementationNow];
	return YES;
}

- (BOOL)popController
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	return [super popController];
}

-(BOOL)popControllerWithAnimation:(BOOL)animation
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	return [super popControllerWithAnimation:animation];
}

- (void)popNavigationItemWithAnimation:(BOOL)animated
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super popNavigationItemWithAnimation:animated];
}

-(void)navigationBarButtonClicked:(int)clicked
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super navigationBarButtonClicked:clicked];
}

- (void)popNavigationItem
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super popNavigationItem];
}


- (void)viewWillDisappear
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super viewWillDisappear];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
	return nil;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
	return 2;
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString *reuseIdentifier = [NSString stringWithFormat:@"ApplicationCell%d%d", indexPath.section, indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[[DSApplicationCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	switch (indexPath.row) {
		case 0:
			passField.frame = CGRectMake(10.0f,10.0f, cell.contentView.frame.size.width - 40.0f, cell.contentView.frame.size.height - 20.0f);
			[cell.contentView addSubview:passField];
			break;
		case 1:
			passField2.frame = CGRectMake(10.0f,10.0f, cell.contentView.frame.size.width - 40.0f, cell.contentView.frame.size.height - 20.0f);
			[cell.contentView addSubview:passField2];
			break;
		default:
			cell.textLabel.text = @"Faulty Cell";
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end

extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
extern NSString * SBSCopyIconImagePathForDisplayIdentifier(NSString *identifier);

@interface DSPreferencesController : PSViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITextField *passField;
	int _use;
	UIKeyboard *_keyBoard;
	UITableView *_tableView;
	NSMutableArray *appStore;
	NSMutableArray *system;
	NSMutableArray *_lockedApps;
	BOOL _locked;
	BOOL _correctPass;
	BOOL _passwordDirectly;
	UITextView *_tutorial;
}
- (UIView *)view;
- (void)setNavigationTitle:(NSString *)navigationTitle;
- (void)loadFromSpecifier:(PSSpecifier *)specifier;

@end

@implementation DSPreferencesController

- (void)viewWillAppear:(BOOL)animated
{
	if (_correctPass) {
		NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"] ?: [[NSDictionary alloc] init];
		passField.text = [prefs objectForKey:@"password"] ?: @"alpine";
		[prefs release];
	}
	[super viewWillAppear:animated];
}

- (void)viewWillRedisplay
{
	if (_correctPass) {
		NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"] ?: [[NSDictionary alloc] init];
		passField.text = [prefs objectForKey:@"password"] ?: @"alpine";
		[prefs release];
	}
	[super viewWillRedisplay];
}

- (id)initForContentSize:(CGSize)size
{
	return [self init];
}

- (id)init
{
	 if ((self = [super init]) != nil) {
		 
	 }
	return self;
}

- (void)viewWillBecomeVisible:(void *)source
{
	if (source)
		[self loadFromSpecifier:(PSSpecifier *)source];
	[super viewWillBecomeVisible:source];
}

- (void)setSpecifier:(PSSpecifier *)specifier
{
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier
{
	_use = [[specifier propertyForKey:@"use"] intValue];
	_tutorial = nil;
	passField = nil;
	_tableView = nil;
	system = nil;
	appStore = nil;
	_lockedApps = nil;
	switch (_use) {
		case 0:
			passField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f,0.0f,[[UIScreen mainScreen] bounds].size.width - 20.0f, 24.0f)];
			passField.placeholder = @"Password";
			passField.clearButtonMode = UITextFieldViewModeAlways;
			passField.autocorrectionType = UITextAutocorrectionTypeNo;
			passField.secureTextEntry = YES;
			passField.font = [UIFont systemFontOfSize:16.0f];
			passField.backgroundColor = [UIColor clearColor];
			passField.textAlignment = UITextAlignmentCenter;
			passField.delegate = self;
			_correctPass = NO;
			if isWildcat
				[UIKeyboard initImplementationNow];
			else
				_keyBoard = [UIKeyboard automaticKeyboard];
			
			[_keyBoard orderInWithAnimation:YES];
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
			[_tableView setDataSource:self];
			[_tableView setDelegate:self];
			system = [[NSMutableArray alloc] init];
			NSMutableArray *paths = [NSMutableArray array];
			
			// ... scan /Applications (System/Jailbreak applications)
			NSFileManager *fileManager = [NSFileManager defaultManager];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/Applications"]) {
				if ([path hasSuffix:@".app"] && ![path hasPrefix:@"."])
					[paths addObject:[NSString stringWithFormat:@"/Applications/%@", path]];
			}
			NSMutableArray *identifiers = [NSMutableArray array];
			
			for (NSString *path in paths) {
				NSBundle *bundle = [NSBundle bundleWithPath:path];
				if (bundle) {
					NSString *identifier = [bundle bundleIdentifier];
					if (isWildcat || [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
						if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileipod"]) {
							[identifiers addObject:@"com.apple.mobileipod-AudioPlayer"];
							[identifiers addObject:@"com.apple.mobileipod-VideoPlayer"];
							identifier = nil;
						} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileslideshow"]) {
							[identifiers addObject:@"com.apple.mobileslideshow-Photos"];
							
							identifier = nil;
						}
					} else {
						if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileipod"]) {
							[identifiers addObject:@"com.apple.mobileipod-MediaPlayer"];
							identifier = nil;
						} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileslideshow"]) {
							[identifiers addObject:@"com.apple.mobileslideshow-Photos"];
							[identifiers addObject:@"com.apple.mobileslideshow-Camera"];
							identifier = nil;
						}
					}
					// Filter out non-applications and apps that should remain hidden
					// FIXME: The proper fix is to only show non-hidden apps and apps
					//        that are in Categories; unfortunately, the design of
					//        Categories does not make it easy to determine what apps
					//        a given folder contains.
					if (identifier &&
						![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
						![identifier isEqualToString:@"com.apple.webapp"])
						[identifiers addObject:identifier];
				}
			}
			[system setArray:identifiers];
			[identifiers removeAllObjects];
			[paths removeAllObjects];
			appStore = [[NSMutableArray alloc] init];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/var/mobile/Applications"]) {
				for (NSString *subpath in [fileManager directoryContentsAtPath:
										   [NSString stringWithFormat:@"/var/mobile/Applications/%@", path]]) {
					if ([subpath hasSuffix:@".app"])
						[paths addObject:[NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", path, subpath]];
				}
			}
			for (NSString *path in paths) {
				NSBundle *bundle = [NSBundle bundleWithPath:path];
				if (bundle) {
					NSString *identifier = [bundle bundleIdentifier];
					// Filter out non-applications and apps that should remain hidden
					// FIXME: The proper fix is to only show non-hidden apps and apps
					//        that are in Categories; unfortunately, the design of
					//        Categories does not make it easy to determine what apps
					//        a given folder contains.
					if (identifier &&
						![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
						![identifier isEqualToString:@"com.apple.webapp"])
						[identifiers addObject:identifier];
				}
			}
			[appStore setArray:identifiers];
			NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"];
			_lockedApps = [[NSMutableArray alloc] initWithArray:(NSArray *)[prefs objectForKey:@"lockedapps"]];
			_locked = [prefs objectForKey:@"locked"] ? [[prefs objectForKey:@"locked"] boolValue] : NO;
			_passwordDirectly = [prefs objectForKey:@"passworddirectly"] ? [[prefs objectForKey:@"passworddirectly"] boolValue] : YES;
			[prefs release];
			break;
		case 1:
			_tutorial = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,0.0f, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f)];
			_tutorial.font = [UIFont systemFontOfSize:16.0f];
			_tutorial.text = @"Welcome to DisplayController!\n\nYou can lock apps by going into the first panel. The default password is alpine. You can change this password in that panel at any time. Just dont forget your password! App reordering allows other tweaks to reorder the current applications that are open. Overriding animations allows this tweak to use it's animation setting rather than the system default or another tweak's animation setting. Enjoy!\n\nAny concerns can be sent to daniel.zimmerman@me.com\n\n";
			_tutorial.editable = NO;
			break;
		default:
			break;
	}
	[self setNavigationTitle:[self navigationTitle]];
}			 

- (void) dealloc {
	if (system)
		[system release];
	if (appStore)
		[appStore release];
	if (_lockedApps)
		[_lockedApps release];
	if (_tableView)
		[_tableView release];
	if (_tutorial)
		[_tutorial release];
	[super dealloc];
}

- (NSString *) navigationTitle {
	switch (_use) {
		case 0:
			return @"Password";
			break;
		case 1:
			return @"Tutorial";
			break;
		default:
			return @"Wrong use";
			break;
	}
}

- (void)setNavigationTitle:(NSString *)navigationTitle
{
	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:navigationTitle];
}

- (id) view
{
	switch (_use) {
		case 0:
			return _tableView;
			break;
		case 1:
			return _tutorial;
			break;
		default:
			return nil;
			break;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"];
	if ([textField.text isEqualToString:([prefs objectForKey:@"password"] ?: @"alpine")]) {
		_correctPass = YES;
		[_tableView reloadData];
		[prefs release];
		if (!isWildcat)
			[_keyBoard orderOutWithAnimation:YES];
		return YES;
	} else {
		[prefs release];
		return NO;
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if isWildcat {
		[UIKeyboard initImplementationNow];
	} else {
		[_keyBoard orderInWithAnimation:YES];
	}
	return YES;
}

- (BOOL)popController
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	return [super popController];
}

-(BOOL)popControllerWithAnimation:(BOOL)animation
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	return [super popControllerWithAnimation:animation];
}

- (void)popNavigationItemWithAnimation:(BOOL)animated
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super popNavigationItemWithAnimation:animated];
}

-(void)navigationBarButtonClicked:(int)clicked
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super navigationBarButtonClicked:clicked];
}

- (void)popNavigationItem
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super popNavigationItem];
}


- (void)viewWillDisappear
{
	if (!isWildcat)
		[_keyBoard orderOutWithAnimation:YES];
	[super viewWillDisappear];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!_correctPass)
		return 1;
	else
		return 4;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
	switch (section) {
		case 0:
			return @"Enter Password:";
			break;
		case 1:
			return nil;
			break;
		case 2:
			return @"System";
			break;
		case 3:
			return @"App Store";
			break;
		default:
			return nil;
			break;
	}
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 3;
			break;
		case 2:
			return [system count];
			break;
		case 3:
			return [appStore count];
			break;
		default:
			return 0;
			break;
	}
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString *reuseIdentifier = [NSString stringWithFormat:@"ApplicationCell%d%d", indexPath.section, indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[[DSApplicationCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	UISwitch *lockedSwitch = nil;
	NSString *identifier;
	NSString *displayName;
	NSString *iconPath;
	UIImage *icon = nil;
	switch (indexPath.section) {
		case 0:
			passField.frame = CGRectMake(10.0f,10.0f, cell.contentView.frame.size.width - 40.0f, cell.contentView.frame.size.height - 20.0f);
			[cell.contentView addSubview:passField];
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Set New Password";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell.textLabel.text = @"Lock Apps";
					lockedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
					lockedSwitch.on = _locked;
					[lockedSwitch addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = lockedSwitch;
					[lockedSwitch release];
					break;
				case 2:
					cell.textLabel.text = @"Password directly";
					lockedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
					lockedSwitch.on = _passwordDirectly;
					[lockedSwitch addTarget:self action:@selector(switchedPassword:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = lockedSwitch;
					[lockedSwitch release];
					break;
				default:
					break;
			}
			[cell imageView].image = nil;
			break;
		case 2:
			cell.accessoryView = nil;
			identifier = [system objectAtIndex:indexPath.row];
			displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
			[cell textLabel].text = displayName;
			[displayName release];
			iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
			if (iconPath != nil) {
				icon = [UIImage imageWithContentsOfFile:iconPath];
				[iconPath release];
			}
			[cell imageView].image = icon;
			cell.accessoryType = [_lockedApps containsObject:[system objectAtIndex:indexPath.row]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		case 3:
			cell.accessoryView = nil;
			identifier = [appStore objectAtIndex:indexPath.row];
			displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
			[cell textLabel].text = displayName;
			[displayName release];
			iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
			if (iconPath != nil) {
				icon = [UIImage imageWithContentsOfFile:iconPath];
				[iconPath release];
			}
			[cell imageView].image = icon;
			cell.accessoryType = [_lockedApps containsObject:[appStore objectAtIndex:indexPath.row]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		default:
			cell.accessoryView = nil;
			cell.textLabel.text = @"Faulty Cell";
			[cell imageView].image = nil;
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"] ?: [[NSMutableDictionary alloc] init];
	UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
	switch (indexPath.section) {
		case 1:
			switch (indexPath.row) {
				case 0:
					[self pushController:[[[DSNewPasswordController alloc] init] autorelease]];
					break;
				default:
					break;
			}
			break;
		case 2:
			if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
				NSLog(@"cell has chheckmark");
				cell.accessoryType = UITableViewCellAccessoryNone;
				if ([_lockedApps containsObject:[system objectAtIndex:indexPath.row]])
					[_lockedApps removeObject:[system objectAtIndex:indexPath.row]];
			} else {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				if (![_lockedApps containsObject:[system objectAtIndex:indexPath.row]])
					[_lockedApps addObject:[system objectAtIndex:indexPath.row]];
			}
			[prefs setObject:_lockedApps forKey:@"lockedapps"];
			break;
		case 3:
			if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
				cell.accessoryType = UITableViewCellAccessoryNone;
				if ([_lockedApps containsObject:[appStore objectAtIndex:indexPath.row]])
					[_lockedApps removeObject:[appStore objectAtIndex:indexPath.row]];
			} else {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				if (![_lockedApps containsObject:[appStore objectAtIndex:indexPath.row]])
					[_lockedApps addObject:[appStore objectAtIndex:indexPath.row]];
			}			
			[prefs setObject:_lockedApps forKey:@"lockedapps"];
			break;
		default:
			break;
	}
	[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist" atomically:YES];
	[prefs release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switched:(UISwitch *)switcher
{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"] ?: [[NSMutableDictionary alloc] init];
	_locked = switcher.on;
	[prefs setObject:[NSNumber numberWithBool:_locked] forKey:@"locked"];
	[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist" atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.zimm.libdisplaystack.settingschanged"), NULL, NULL, true);
	[prefs release];
}

- (void)switchedPassword:(UISwitch *)switcher
{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist"] ?: [[NSMutableDictionary alloc] init];
	_passwordDirectly = switcher.on;
	[prefs setObject:[NSNumber numberWithBool:_passwordDirectly] forKey:@"passworddirectly"];
	[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.libdisplaystack.plist" atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.zimm.libdisplaystack.settingschanged"), NULL, NULL, true);
	[prefs release];
}


@end
