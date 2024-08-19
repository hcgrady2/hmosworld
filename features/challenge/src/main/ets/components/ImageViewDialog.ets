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

import { abilityAccessCtrl, common, ConfigurationConstant } from '@kit.AbilityKit';
import { curves, promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BreakpointTypeEnum, ImageUtil, Logger, WindowUtil } from '@ohos/utils';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';
import ZonesItem from '../model/ZonesItem';
import { ImageSaveDialog } from './ImageSaveDialog';

const TAG = '[ImageViewDialog]';

@Component
export struct ImageViewDialog {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @Consume('introductionData') introductionData: ZonesItem;
  private deviceWidth: number = vp2px(AppStorage.get('deviceWidth') as number);
  private deviceHeight: number = vp2px(AppStorage.get('deviceHeight') as number);
  private imgWidth: number = 0;
  private imgHeight: number = 0;
  private displayHeight: number = 0;
  private preOffsetX: number = 0;
  private preOffsetY: number = 0;
  private curScale: number = 1;
  @State imagePixelMaps: Map<Number, image.PixelMap> = new Map();
  @State isGesture: boolean = false;
  @State imgScale: number = 1;
  @State imgOffsetX: number = 0;
  @State imgOffsetY: number = 0;
  @Link isPresent: boolean;
  @Link currentIndex: number;
  private appContext: common.Context = getContext(this);
  atManager = abilityAccessCtrl.createAtManager();
  // Configuring the Style of the Pop-up Window Displayed When a User Touches and Holds an Image
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ImageSaveDialog({
      save: () => {
        this.SavePicture();
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
    backgroundColor: $r('sys.color.ohos_id_color_sub_background')
  })

  /**
   * Detect boundary to keep the image in window.
   */
  detectBoundary(): void {
    let maxOffsetX = this.imgScale * this.deviceWidth / 2 - this.deviceWidth / 2;
    if (vp2px(this.imgOffsetX) > (maxOffsetX)) {
      this.imgOffsetX = px2vp(maxOffsetX);
    }
    if (vp2px(this.imgOffsetX) < -(maxOffsetX)) {
      this.imgOffsetX = -px2vp(maxOffsetX);
    }
    let maxOffsetY = this.imgScale * this.displayHeight / 2 - this.deviceHeight / 2;
    if (this.imgScale * this.displayHeight >= this.deviceHeight) {
      if (vp2px(this.imgOffsetY) > (maxOffsetY)) {
        this.imgOffsetY = px2vp(maxOffsetY);
      }
      if (vp2px(this.imgOffsetY) < -(maxOffsetY)) {
        this.imgOffsetY = -px2vp(maxOffsetY);
      }
    } else {
      this.imgOffsetY = 0;
    }
  }

  /**
   * Limit scale to keep the image clear.
   */
  limitScale(isReset: boolean): void {
    if (this.imgScale < 1) {
      this.imgScale = 1;
      this.curScale = 1;
      if (isReset) {
        this.imgOffsetX = 0;
        this.imgOffsetY = 0;
      }
      this.isGesture = false;
    } else if (this.imgScale > Const.MAX_SCALE) {
      this.imgScale = Const.MAX_SCALE;
      this.curScale = Const.MAX_SCALE;
    } else {
      this.curScale = this.imgScale;
    }
  }

  aboutToAppear(): void {
    WindowUtil.updateStatusBarColor(getContext(this), true);
    this.introductionData.imageList.forEach(async (item: Resource) => {
      const imagePixelMap = await ImageUtil.getPixmapFromMedia(item);
      this.imagePixelMaps.set(item.id, imagePixelMap);
    });
  }

  aboutToDisappear(): void {
    WindowUtil.updateStatusBarColor(getContext(this),
      AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  async SavePicture(): Promise<void> {
    try {
      // Obtain an instance of an album management module, for accessing and modifying media files in an album.
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.appContext);
      // Create an image file through the createAsset interface.
      let uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg'); // Creating a Media File
      let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE || fileIo.OpenMode.CREATE);
      // Save the picture to the album.
      this.appContext.resourceManager.getMediaContent(this.introductionData.imageList[this.currentIndex].id, 0)
        .then(async (value: Uint8Array) => {
          let media = value.buffer;
          // Write to media library file
          await fileIo.write(file.fd, media);
          await fileIo.close(file.fd);
          this.dialogController.close();
          promptAction.showToast({ message: $r('app.string.save_image_success_prompt_msg') });
        });
    } catch (err) {
      Logger.error(TAG, 'createAsset failed, message = ', err);
    }
  }

  build() {
    Stack() {
      Swiper() {
        ForEach(this.introductionData.imageList, (item: Resource, index?: number) => {
          Column() {
            Blank()
              .onClick(() => {
                animateTo({ duration: Const.SWIPER_DURATION }, () => {
                  this.isPresent = !this.isPresent;
                });
              })
            Image(this.imagePixelMaps.get(item.id))
              .width(Const.FULL_PERCENT)
              .enableAnalyzer(true)
              .syncLoad(true)
              .draggable(false)
              .objectFit(ImageFit.Contain)
              .gesture(
                LongPressGesture({ duration: Const.ANIMATION_DURATION_NORMAL })
                  .onAction((event?: GestureEvent) => {
                    if (event) {
                      this.dialogController.open();
                    }
                  })
              )
              .gesture(
                PinchGesture()
                  .onActionStart(() => {
                    this.isGesture = true;
                  })
                  .onActionUpdate((event?: GestureEvent) => {
                    if (event) {
                      this.imgScale = this.curScale * event.scale;
                    }
                  })
                  .onActionEnd(() => {
                    this.limitScale(false);
                  })
              )
              .geometryTransition(index === this.currentIndex && !this.isGesture ? 'share_' + index : '')
            Blank()
              .onClick(() => {
                animateTo({ duration: Const.SWIPER_DURATION }, () => {
                  this.isPresent = !this.isPresent;
                });
              })
          }
          .width(Const.FULL_PERCENT)
          .height(Const.FULL_PERCENT)
          .justifyContent(FlexAlign.Center)
        })
      }
      .width(Const.FULL_PERCENT)
      .height(Const.FULL_PERCENT)
      .loop(false)
      .indicator(this.currentBreakpoint !== BreakpointTypeEnum.LG ? Indicator.dot()
        .color(Color.Gray)
        .bottom($r('app.float.indicator_bottom')) : false)
      .displayArrow(this.currentBreakpoint === BreakpointTypeEnum.LG ? {
        showBackground: true,
        isSidebarMiddle: true,
        arrowColor: $r('app.color.white'),
        backgroundColor: $r('app.color.arrow_bg_white')
      } : false)
      .index(this.currentIndex)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .visibility(this.isGesture ? Visibility.Hidden : Visibility.Visible)

      Row() {
        Image(this.introductionData.imageList[this.currentIndex])
          .transition(TransitionEffect.OPACITY.animation({
            curve: curves.springMotion(Const.SPRING_RESPONSE, Const.DAMPING_FRACTION)
          }))
          .geometryTransition(this.isGesture ? 'share_' + this.currentIndex : '')
          .enableAnalyzer(true)
          .objectFit(ImageFit.Contain)
          .scale({ x: this.imgScale, y: this.imgScale })
          .translate({ x: this.imgOffsetX, y: this.imgOffsetY })
          .onComplete((event) => {
            if (event) {
              this.imgWidth = event.width;
              this.imgHeight = event.height;
              this.displayHeight = this.deviceWidth * this.imgHeight / this.imgWidth;
            }
          })
      }
      .gesture(
        PinchGesture()
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              this.imgScale = this.curScale * event.scale;
            }
          })
          .onActionEnd(() => {
            this.detectBoundary();
            this.limitScale(true);
          })
      )
      .gesture(
        PanGesture()
          .onActionStart(() => {
            this.preOffsetX = this.imgOffsetX;
            this.preOffsetY = this.imgOffsetY;
          })
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              this.imgOffsetX = this.preOffsetX + event.offsetX;
              this.imgOffsetY = this.preOffsetY + event.offsetY;
            }
          })
          .onActionEnd(() => {
            this.detectBoundary();
          })
      )
      .visibility(this.isGesture ? Visibility.Visible : Visibility.Hidden)
    }
    .onClick(() => {
      animateTo({ duration: Const.SWIPER_DURATION }, () => {
        this.isPresent = !this.isPresent;
      });
    })
  }
}