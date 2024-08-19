/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { picker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import {
  CollaborationServiceFilter,
  CollaborationServiceStateDialog,
  createCollaborationServiceMenuItems
} from '@kit.ServiceCollaborationKit';
import { UserAccount } from '@ohos/login';
import { BreakpointType, BreakpointTypeEnum, CommonConstants, FileUtil, Logger } from '@ohos/utils';
import Constants from '../constants/Constants';
import { ProfileConstants } from '../constants/ProfileConstants';

let breakpointType: BreakpointType<string> = new BreakpointType<string>({
  sm: Constants.IMAGE_RATIO_PHONE,
  md: Constants.IMAGE_RATIO_FOLD,
  lg: Constants.IMAGE_RATIO_PAD
})
let breakpointImage: BreakpointType<Resource> = new BreakpointType<Resource>({
  sm: $r('app.float.safe_logo_margin'),
  md: $r('app.float.fold_image_top'),
  lg: $r('app.float.pad_image_top')
})

const TAG = '[PhotoPage]';

@Component
export struct PhotoView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageProp('user') account: UserAccount | null = null;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @StorageProp('profilePixelMap') profilePixelMap: PixelMap | null = null;
  private isPadOr2in1: boolean = (deviceInfo.deviceType === '2in1' || deviceInfo.deviceType === 'tablet');

  @Builder
  MenuBuilder() {
    Text($r('app.string.use_local_device'))
      .fontColor('#99000000')
      .fontSize($r('app.float.menu_font_size'))
      .padding({ left: $r('app.float.menu_padding') })
      .height($r('app.float.menu_height'))
  }

  @Builder
  SelectProfileMenu() {
    Menu() {
      MenuItem(this.MenuBuilder())
      MenuItem({ content: $r('app.string.select_from_gallery'), startIcon: $r('sys.media.ohos_ic_public_albums') })
        .padding({ left: $r('app.float.menu_padding') })
        .onClick(() => {
          this.selectPicture();
        })
    }

    Menu() {
      createCollaborationServiceMenuItems([CollaborationServiceFilter.ALL])
    }
  }

  doSavePicture(stateCode: number, _bufferType: string, buffer: ArrayBuffer): void {
    if (stateCode === 0) {
      let imageSource = image.createImageSource(buffer);
      FileUtil.saveBuffer2File(ProfileConstants.LOCAL_PROFILE_PATH, buffer);
      FileUtil.saveBuffer2File(ProfileConstants.DISTRIBUTED_PROFILE_PATH, buffer);
      imageSource.createPixelMap().then((pixelMap) => {
        AppStorage.setOrCreate('profilePixelMap', pixelMap);
      })
    }
  }

  selectPicture() {
    const photoSelectOptions = new picker.PhotoSelectOptions();
    photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1;
    const photoViewPicker = new picker.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: picker.PhotoSelectResult) => {
      let uris: Array<string> = photoSelectResult.photoUris;
      if (uris.length > 0) {
        this.appPathStack.replacePathByName('ConfirmView', new Object({ uri: uris[0] }));
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `picker select failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_public_cancel'))
            .height($r('app.float.normal_icon_size'))
            .width($r('app.float.normal_icon_size'))
            .fillColor(Color.White)
            .onClick(() => {
              this.appPathStack.pop();
            })
        }
        .padding({ top: $r('app.float.md_padding_margin') })
        .justifyContent(FlexAlign.Start)
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          top: AppStorage.get('statusBarHeight') as number,
          left: $r('app.float.xxl_padding_margin'),
          bottom: breakpointImage.getValue(this.currentBreakpoint)
        })

        Row() {
          Image(this.profilePixelMap !== null ? this.profilePixelMap : this.account?.portrait)
            .aspectRatio(1)
            .clipShape(new Circle({ height: Constants.CLIP_RATIO, width: Constants.CLIP_WIDTH })
              .position({
                y: Constants.CIRCLE_RATIO_Y,
                x: Constants.CLIP_MARGIN
              })
            )
        }
        .height(breakpointType.getValue(this.currentBreakpoint))

        CollaborationServiceStateDialog({
          onState: (stateCode: number, bufferType: string, buffer: ArrayBuffer): void => this.doSavePicture(stateCode,
            bufferType, buffer)
        })

        Row() {
          Button($r('app.string.editPhoto'))
            .backgroundColor($r('app.color.back_color'))
            .fontColor($r('app.color.font_color'))
            .type(ButtonType.Capsule)
            .size({
              width: $r('app.float.button_change_width'),
              height: $r('app.float.button_height')
            })
            .margin({ top: $r('app.float.tab_big_img_width') })
            .bindMenu(this.isPadOr2in1 ? this.SelectProfileMenu() : undefined)
            .onClick(() => {
              if (!this.isPadOr2in1) {
                this.selectPicture();
              }
            })
        }
      }
      .backgroundColor(Color.Black)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        top: AppStorage.get<number>('statusBarHeight'),
        bottom: (AppStorage.get<number>('naviIndicatorHeight') || 0) + Constants.PHOTO_PADDING_BOTTOM
      })
    }
    .hideTitleBar(true)
  }
}

@Builder
export function PhotoViewBuilder() {
  PhotoView();
}