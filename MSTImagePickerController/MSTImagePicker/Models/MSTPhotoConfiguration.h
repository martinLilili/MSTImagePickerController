//
//  MSTPhotoConfiguration.h
//  MSTImagePickerController
//
//  Created by Mustard on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSTImageMomentGroupType) {
    MSTImageMomentGroupTypeNone,          //无分组
    MSTImageMomentGroupTypeYear,          //年
    MSTImageMomentGroupTypeMonth,         //月
    MSTImageMomentGroupTypeDay            //日
};

@interface MSTPhotoConfiguration : NSObject
/**
 是否多选，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsMutiSelected;

/**
 最大选择个数，只在多选(allowsMutiSelected)为 YES 时可用，默认为 9
 */
@property (assign, nonatomic) int maxSelectCount;

/**
 一行显示多少个，默认为 4
 */
@property (assign, nonatomic) int numsInRow;

/**
 是否有蒙版，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsMasking;

/**
 是否有选中动画，默认为 YES
 */
@property (assign, nonatomic) BOOL allowsSelectedAnimation;

/**
 图片分组类型，默认为 MSTImageGroupTypeNone
 */
@property (assign, nonatomic) MSTImageMomentGroupType photoMomentGroupType;

/**
 图片是否为降序排列，默认为 YES
 */
@property (assign, nonatomic) BOOL isPhotosDesc;

/**
 是否显示相册缩略图，默认为 YES
 */
@property (assign, nonatomic) BOOL isShowAlbumThumbnail;

/**
 是否显示相册包含图片个数，默认为 YES
 */
@property (assign, nonatomic) BOOL isShowAlbumNumber;

/**
 是否显示空相册，默认为 NO
 */
@property (assign, nonatomic) BOOL isShowEmptyAlbum;

/**
 是否只显示图片，默认为 NO
 */
@property (assign, nonatomic) BOOL isOnlyShowImages;

/**
 是否显示 Live Photo 图标，默认为 YES
 */
@property (assign, nonatomic) BOOL isShowLivePhotoIcon;

/**
 第一个图标是否为相机，默认为 YES
 */
@property (assign, nonatomic) BOOL isFirstCamera;


/**
 单例方法
 */
+ (instancetype)defaultConfiguration;

@end