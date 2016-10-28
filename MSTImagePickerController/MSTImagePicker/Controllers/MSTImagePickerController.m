//
//  MSTImagePickerController.m
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/9.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import "MSTImagePickerController.h"
#import "MSTPhotoConfiguration.h"
#import "MSTAlbumListController.h"
#import "MSTPhotoGridController.h"
#import "UIViewController+MSTUtils.h"
#import "MSTPhotoManager.h"
#import "MSTAlbumModel.h"

@interface MSTImagePickerController ()

@property (strong, nonatomic) MSTPhotoConfiguration *config;

@property (assign, nonatomic) MSTImagePickerAccessType accessType;

@property (strong, nonatomic) MSTAlbumListController *albumListController;
@property (strong, nonatomic) MSTPhotoGridController *photoGridController;

@property (strong, nonatomic) UIAlertController *maxSelectedAlertController;

@property (strong, nonatomic) NSMutableArray <MSTAssetModel *>*pickedModels;
@property (strong, nonatomic) NSMutableArray <NSString *>*pickedModelIdentifiers;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *originalImageButton;
@property (strong, nonatomic) UIButton *originalTextButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *pickedCountLabel;

@end

@implementation MSTImagePickerController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setToolbarHidden:NO animated:NO];
    
    [self mp_setupNavigationBar];
    [self mp_setupToolBar];
    [self mp_checkAuthorizationStatus];
}

#pragma mark - Initialization Methods
- (instancetype)initWithAccessType:(MSTImagePickerAccessType)accessType{
    if (self = [super init]) {
        self.accessType = accessType;
        self.albumTitle = NSLocalizedStringFromTable(@"str_photos", @"MSTImagePicker", @"相册");
    }
    return self;
}

#pragma mark - Instance Methods
- (BOOL)addSelectedAsset:(MSTAssetModel *)asset {
    if (self.pickedModels.count == self.config.maxSelectCount) {
        
        [self presentViewController:self.maxSelectedAlertController animated:YES completion:nil];
        
        return NO;
    }
    
    //已经保存过
    if ([self containAssetModel:asset]) return YES;
    
    asset.selected = YES;
    [self.pickedModels addObject:asset];
    [self.pickedModelIdentifiers addObject:asset.identifier];
    
    return YES;
}

- (BOOL)removeSelectedAsset:(MSTAssetModel *)asset {
    if ([self.pickedModelIdentifiers containsObject:asset.identifier]) {
        asset.selected = NO;
        
        NSInteger index = [self.pickedModelIdentifiers indexOfObject:asset.identifier];
        
        [self.pickedModelIdentifiers removeObjectAtIndex:index];
        [self.pickedModels removeObjectAtIndex:index];
        
        return YES;
    }
    return NO;
}

- (BOOL)containAssetModel:(MSTAssetModel *)asset {
    return [self.pickedModelIdentifiers containsObject:asset.identifier];
}

/**
 检查授权访问状态
 */
- (void)mp_checkAuthorizationStatus {
    [MSTPhotoManager checkAuthorizationStatusWithSourceType:MSTImagePickerSourceTypePhoto callBack:^(MSTImagePickerSourceType sourceType, MSTAuthorizationStatus status) {
        switch (status) {
            case MSTAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case MSTAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
            case MSTAuthorizationStatusDenied:{
                NSLog(@"PHAuthorizationStatusDenied");
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTable(@"str_allow_photoLibrary", @"MSTImagePicker", @"允许访问") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"str_confirm", @"MSTImagePicker", @"确认") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
                
                break;
            }
            case MSTAuthorizationStatusAuthorized:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (_accessType) {
                        case MSTImagePickerAccessTypeAlbums: {
                            [self setViewControllers:@[self.albumListController]];
                        }
                            break;
                        case MSTImagePickerAccessTypePhotosWithAlbums: {
                            [self setViewControllers:@[self.albumListController, self.photoGridController]];
                        }
                            break;
                        case MSTImagePickerAccessTypePhotosWithoutAlbums: {
                            [self setViewControllers:@[self.photoGridController] animated:YES];
                        }
                            break;
                    }
                    NSLog(@"PHAuthorizationStatusAuthorized");
                });
                break;
            }
            default:
                break;
        }
    }];
}

- (void)mp_setupNavigationBar {
    switch (self.config.themeStyle) {
        case MSTImagePickerStyleLight:
            self.navigationBar.barStyle = UIBarStyleDefault;
            self.navigationBar.translucent = YES;
            break;
        case MSTImagePickerStyleDark:
            self.navigationBar.barStyle = UIBarStyleBlack;
            self.navigationBar.translucent = YES;
            self.navigationBar.tintColor = [UIColor whiteColor];
            break;
    }
}

- (void)mp_setupToolBar {
    [self.previewButton setEnabled:NO];
}

- (CGFloat)mp_calculateWidthWithString:(NSString *)string {
    return [string boundingRectWithSize:CGSizeMake(300, 44) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil].size.width;
}

- (void)mp_previewButtonDidClicked {
    NSLog(@"Preview Button Did Clicked.");
}

- (void)mp_doneButtonDidClicked {
    NSLog(@"Done Button Did Clicked.");
}

- (void)mp_originalImageButtonDidClicked {
    NSLog(@"Full Image Button Did Clicked.");
}

#pragma mark - Lazy Load
- (MSTPhotoConfiguration *)config {
    if (!_config) {
        self.config = [MSTPhotoConfiguration defaultConfiguration];
    }
    return _config;
}

- (MSTAlbumListController *)albumListController{
    if (!_albumListController) {
        self.albumListController = [[MSTAlbumListController alloc] init];
    }
    return _albumListController;
}

- (MSTPhotoGridController *)photoGridController{
    if (!_photoGridController) {
        self.photoGridController = [[MSTPhotoGridController alloc] initWithCollectionViewLayout:[MSTPhotoGridController flowLayoutWithNumInALine:self.config.numsInRow]];
        [[MSTPhotoManager alloc] loadCameraRollInfoisDesc:self.config.isPhotosDesc isShowEmpty:self.config.isShowEmptyAlbum isOnlyShowImage:self.config.isOnlyShowImages CompletionBlock:^(MSTAlbumModel *result) {
            _photoGridController.album = result;
        }];
    }
    return _photoGridController;
}

- (UIAlertController *)maxSelectedAlertController {
    if (!_maxSelectedAlertController) {
        self.maxSelectedAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"str_get_to_maximum_selected", @"MSTImagePicker", @"最大选择数量提示"), self.config.maxSelectCount] message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"str_i_see", @"MSTImagePicker", @"我知道了") style:UIAlertActionStyleDefault handler:nil];
        [_maxSelectedAlertController addAction:okAction];
    }
    return _maxSelectedAlertController;
}

- (NSMutableArray *)pickedModels {
    if (!_pickedModels) {
        self.pickedModels = [NSMutableArray array];
    }
    return _pickedModels;
}

- (NSMutableArray<NSString *> *)pickedModelIdentifiers {
    if (!_pickedModelIdentifiers) {
        self.pickedModelIdentifiers = [NSMutableArray array];
    }
    return _pickedModelIdentifiers;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_preview", @"MSTImagePicker", @"预览");

        self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(0, 0, [self mp_calculateWidthWithString:string] + 20, 44);
        _previewButton.backgroundColor = [UIColor orangeColor];
        [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

        _previewButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_previewButton setTitle:string forState:UIControlStateNormal];

        [_previewButton addTarget:self action:@selector(mp_previewButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_previewButton];
    }
    return _previewButton;
}

- (UIButton *)originalImageButton {
    return _originalImageButton;
}

- (UIButton *)originalTextButton {
    return _originalTextButton;
}

- (UIButton *)doneButton {
    return _doneButton;
}

- (UILabel *)pickedCountLabel {
    return _pickedCountLabel;
}

#pragma mark - Setter
- (void)setAllowsMutiSelected:(BOOL)allowsMutiSelected {
    self.config.allowsMutiSelected = allowsMutiSelected;
}

- (void)setMaxSelectCount:(int)maxSelectCount {
    self.config.maxSelectCount = maxSelectCount;
}

- (void)setNumsInRow:(int)numsInRow {
    self.config.numsInRow = numsInRow;
}

- (void)setAllowsMasking:(BOOL)allowsMasking {
    self.config.allowsMasking = allowsMasking;
}

- (void)setAllowsSelectedAnimation:(BOOL)allowsSelectedAnimation {
    self.config.allowsSelectedAnimation = allowsSelectedAnimation;
}

- (void)setThemeStyle:(MSTImagePickerStyle)themeStyle {
    self.config.themeStyle = themeStyle;
}

- (void)setPhotoMomentGroupType:(MSTImageMomentGroupType)photoMomentGroupType {
    self.config.photoMomentGroupType = photoMomentGroupType;
}

- (void)setIsPhotosDesc:(BOOL)isPhotosDesc {
    self.config.isPhotosDesc = isPhotosDesc;
}

- (void)setIsShowAlbumThumbnail:(BOOL)isShowAlbumThumbnail {
    self.config.isShowAlbumThumbnail = isShowAlbumThumbnail;
}

- (void)setIsShowAlbumNumber:(BOOL)isShowAlbumNumber {
    self.config.isShowAlbumNumber = isShowAlbumNumber;
}

- (void)setIsShowEmptyAlbum:(BOOL)isShowEmptyAlbum {
    self.config.isShowEmptyAlbum = isShowEmptyAlbum;
}

- (void)setIsOnlyShowImages:(BOOL)isOnlyShowImages {
    self.config.isOnlyShowImages = isOnlyShowImages;
}

- (void)setIsShowLivePhotoIcon:(BOOL)isShowLivePhotoIcon {
    self.config.isShowLivePhotoIcon = isShowLivePhotoIcon;
}

- (void)setIsFirstCamera:(BOOL)isFirstCamera {
    self.config.isFirstCamera = isFirstCamera;
}

- (void)setAllowsMakingVideo:(BOOL)allowsMakingVideo {
    self.config.allowsMakingVideo = allowsMakingVideo;
}

- (void)setAllowsPickGIF:(BOOL)allowsPickGIF {
    self.config.allowsPickGIF = allowsPickGIF;
}

- (void)setVideoMaximumDuration:(NSTimeInterval)videoMaximumDuration {
    self.config.videoMaximumDuration = videoMaximumDuration;
}

- (void)setCustomAlbumName:(NSString *)customAlbumName {
    self.config.customAlbumName = customAlbumName;
}

- (void)setAlbumTitle:(NSString *)albumTitle {
    self.albumListController.title = _albumTitle;
}

- (void)setAlbumPlaceholderThumbnail:(UIImage *)albumPlaceholderThumbnail {
    self.albumListController.placeholderThumbnail = albumPlaceholderThumbnail;
}

- (void)setPhotoNormal:(UIImage *)photoNormal {
    self.config.photoNormal = photoNormal;
}

- (void)setPhotoSelected:(UIImage *)photoSelected {
    self.config.photoSelected = photoSelected;
}

- (void)setCameraImage:(UIImage *)cameraImage {
    self.config.cameraImage = cameraImage;
}

@end




















