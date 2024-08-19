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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { TopNavigationView } from '@ohos/uicomponents';
import {
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  FileUtil,
  Logger,
  WindowUtil
} from '@ohos/utils';
import Constants from '../constants/Constants';
import { ProfileConstants } from '../constants/ProfileConstants';

const TAG = '[ConfirmPage]';

let imageWidth: BreakpointType<string> = new BreakpointType<string>({
  sm: CommonConstants.FULL_PERCENT,
  md: Constants.CLIP_RATIO_FOLD,
  lg: Constants.CLIP_RATIO_PAD
})

@Component
export struct ConfirmView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State uri: string = '';
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  onBackPress(): boolean {
    this.checkBackAction(true);
    return true;
  }

  @Builder
  MenuBuilder() {
    Image($r('app.media.ic_public_ok'))
      .height($r('app.float.normal_icon_size'))
      .width($r('app.float.normal_icon_size'))
      .fillColor(Color.Black)
      .onClick(() => this.savePhoto())
  }

  async savePhoto() {
    FileUtil.copyFile(this.uri, ProfileConstants.LOCAL_PROFILE_PATH);
    FileUtil.copyFile(this.uri, ProfileConstants.DISTRIBUTED_PROFILE_PATH);
    let imageSource: image.ImageSource = image.createImageSource(ProfileConstants.LOCAL_PROFILE_PATH);
    imageSource.createPixelMap((err, pixelMap) => {
      AppStorage.setOrCreate('profilePixelMap', pixelMap);
      this.appPathStack.pop();
      Logger.error(TAG, `createPixelMap error: ${err}`)
    });
  }

  checkBackAction(isCenter?: boolean) {
    AlertDialog.show(
      {
        message: $r('app.string.sure_cancel'),
        autoCancel: false,
        alignment: this.currentBreakpoint === (BreakpointTypeEnum.SM || isCenter) ? DialogAlignment.Center :
        DialogAlignment.TopStart,
        offset: this.currentBreakpoint === (BreakpointTypeEnum.SM || isCenter) ? { dx: 0, dy: 0 } : {
          dx: $r('app.float.xxl_padding_margin'),
          dy: Constants.NAVIGATION_HEIGHT + (AppStorage.get<number>('statusBarHeight') || 0)
        },
        gridCount: 4,
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
            Logger.info(TAG, 'Button-clicking callback');
          }
        },
        secondaryButton: {
          value: $r('app.string.sure'),
          action: () => {
            Logger.info(TAG, 'Button-clicking callback');
            FileUtil.deleteFile(ProfileConstants.DISTRIBUTED_PROFILE_PATH);
            this.appPathStack.pop();
          }
        }
      }
    )
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          onBackClick: () => {
            this.checkBackAction();
          },
          title: $r('app.string.crop_photo'),
          menuView: () => this.MenuBuilder()
        })

        Stack() {
          Image(this.uri)
            .maskShape(new Rect({
              width: CommonConstants.FULL_PERCENT,
              height: CommonConstants.FULL_PERCENT
            }).fill(Color.Gray))
            .aspectRatio(Constants.CLIP_RATIO_PHONE)
          Image(this.uri)
            .aspectRatio(Constants.CLIP_RATIO_PHONE)
            .clipShape(new Circle({ height: Constants.CLIP_RATIO, width: Constants.CLIP_WIDTH })
              .position({
                y: Constants.CIRCLE_RATIO_Y,
                x: Constants.CLIP_MARGIN
              })
            )
        }
        .margin({ top: $r('app.float.xxl_padding_margin') })
        .width(imageWidth.getValue(this.currentBreakpoint))
      }
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .padding({
        top: AppStorage.get<number>('statusBarHeight'),
        bottom: AppStorage.get<number>('naviIndicatorHeight') || 0
      })
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .onReady((cxt: NavDestinationContext) => {
      this.uri = (cxt.pathInfo.param as Record<string, string>).uri;
    })
    .onShown(() => {
      WindowUtil.updateStatusBarColor(getContext(this),
        AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    })
    .onHidden(() => {
      WindowUtil.updateStatusBarColor(getContext(this), true);
    })
    .onBackPressed(() => {
      return this.onBackPress();
    })
  }
}

@Builder
export function PhotoConfirmBuilder() {
  ConfirmView();
}