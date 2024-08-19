/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { util } from '@kit.ArkTS';
import { curves } from '@kit.ArkUI';
import { avSession } from '@kit.AVSessionKit';
import { AudioPlayerService } from '@ohos/audioplayer';
import { BreakpointType, BreakpointTypeEnum, CommonConstants, ImageUtil, Logger } from '@ohos/utils';
import ZonesItem from '../model/ZonesItem';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';
import { ZoneDetailView } from '../views/ZoneDetailView';
import { SpeakPlayerButton } from './SpeakPlayerButton';

const resourceManager = getContext().resourceManager;
export enum ModalActionType {
  ROUTE = 0,
  NAVIGATION
}

const TAG = '[ZoneDetailModal]';

@Component
export struct ZoneDetailModal {
  clickAction: Function = (actionType: ModalActionType) => {
  };
  currentHeight: number = 0;
  currentPositionX: number = 0;
  minPositionX: number = 24;
  maxPositionX: number = 0;
  @Link showDetail: boolean;
  @Prop distance: string = '';
  @State detailSheetMinHeight: number = 0;
  @State detailSheetMaxHeight: number = 0;
  @Consume('positionX') positionX: number;
  @Link detailSheetHeight: number;
  @StorageProp('currentBreakpoint') @Watch('handleShowChange') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @StorageProp('deviceWidth') @Watch('handleShowChange') deviceWidth: number =
    AppStorage.get('deviceWidth') as number;
  @State detailSheetWidth: Length =
    this.currentBreakpoint === BreakpointTypeEnum.SM ? CommonConstants.FULL_PERCENT : Const.MODAL_MAX_WIDTH;
  @Consume('introductionData') selectedZone: ZonesItem;
  interpolatingCurve: ICurve = curves.interpolatingSpring(0, 1, 328, 36);

  aboutToAppear(): void {
    this.handleShowChange();
  }
  // 当模态弹窗显隐发生改变时，重新计算弹窗的尺寸
  handleShowChange() {
      this.detailSheetWidth =
        this.currentBreakpoint === BreakpointTypeEnum.SM ? this.deviceWidth :
        Const.MODAL_MAX_WIDTH;
      this.detailSheetMinHeight = this.detailSheetWidth * Const.IMG_ASPECT_RATIO + Const.MODAL_BOTTOM_HEIGHT;
      this.detailSheetHeight = this.detailSheetMinHeight;
      let tempHeight: number =
        (AppStorage.get('deviceHeight') as number) - (AppStorage.get('statusBarHeight') as number) - 8 -
          (AppStorage.get('naviIndicatorHeight') as number);
      if (this.currentBreakpoint !== BreakpointTypeEnum.LG) {
        tempHeight -= Const.TABBAR_HEIGHT;
      }
      if (this.currentBreakpoint === BreakpointTypeEnum.MD) {
        tempHeight -= 20;
      }
      this.detailSheetMaxHeight = tempHeight;
      this.maxPositionX = this.deviceWidth - Const.MODAL_MAX_WIDTH - this.minPositionX;
      if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
        this.maxPositionX -= Const.TABBAR_WIDTH;
      }

      Logger.info(TAG, `maxHeight:${this.detailSheetMaxHeight}   minHeight: ${this.detailSheetMinHeight}`);
  }

  @Builder
  DragBar() {
    Column() {
      Row()
        .height($r('app.float.drag_bar_height'))
        .width($r('app.float.drag_bar_width'))
        .backgroundColor($r('sys.color.ohos_id_color_fourth'))
        .borderRadius($r('app.float.drag_bar_border_radius'))
        .margin({
          top: $r('app.float.sm_padding_margin'),
          bottom: $r('app.float.xs_padding_margin')
        })
    }
    .gesture(
      PanGesture({
        direction: this.currentBreakpoint === BreakpointTypeEnum.SM ? PanDirection.None : PanDirection.Horizontal
      })
        .onActionStart((event: GestureEvent) => {
          Logger.info(TAG, `Bar PanGesture start:   ${JSON.stringify(event)}`);
          this.currentPositionX = this.positionX;
        })
        .onActionUpdate((event: GestureEvent) => {
          Logger.info(TAG, `Bar PanGesture update:   ${JSON.stringify(event)}`);
          let offsetX: number = event.offsetX;
          animateTo({
            curve: this.interpolatingCurve
          }, () => {
            this.positionX = this.currentPositionX + offsetX;
          });
        })
        .onActionEnd((event: GestureEvent) => {
          Logger.info(TAG, `Bar PanGesture end:   ${JSON.stringify(event)}`);
          let rightThreshold: number = (this.maxPositionX - this.minPositionX) / 2 + this.minPositionX;
          animateTo({
            curve: this.interpolatingCurve
          }, () => {
            this.positionX = this.positionX > rightThreshold ? this.maxPositionX : this.minPositionX;
          });
        }))
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Transparent)
  }

  // get text of whole zone item
  getAllText(): string {
    const contentText: string = this.selectedZone.content.map((res: ResourceStr) => typeof res === 'string' ?
      res : resourceManager.getStringSync(res)).join('');
    return contentText + resourceManager.getStringSync(this.selectedZone.buildingInformation);
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        ZoneDetailView({
          detailSheetHeight: $detailSheetHeight,
          detailSheetMinHeight: this.detailSheetMinHeight,
          detailSheetMaxHeight: this.detailSheetMaxHeight
        })
        this.DragBar()
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_modal_close'))
            .height($r('app.float.sm_icon_size'))
        }
        .width($r('app.float.md_btn_height'))
        .height($r('app.float.md_btn_height'))
        .backgroundColor($r('app.color.btn_bg_color'))
        .backgroundBlurStyle(BlurStyle.Thin, { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.AVERAGE })
        .margin({ top: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
        .onClick(() => {
          this.showDetail = false;
          this.detailSheetHeight = this.detailSheetMinHeight;
          AudioPlayerService.getInstance().stop();
        })
        SpeakPlayerButton({
          speakText: this.getAllText(),
          onInitSpeak: async () => {
            const swiperImagePixMap = await ImageUtil.getPixmapFromMedia(this.selectedZone.swiperPic);
            AppStorage.setOrCreate<avSession.AVMetadata>('avMetadata', {
              assetId: util.generateRandomUUID(false),
              mediaImage: swiperImagePixMap
            })
          }
        })
          .margin({ top: $r('app.float.lg_padding_margin'), right: 72 })
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)

      Column({ space: CommonConstants.SPACE_12 }) {
        Row() {
          Text(this.selectedZone.title)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontSize($r('app.float.duration_font_size'))
            .fontWeight(FontWeight.Medium)
          Text(this.distance ? $r('app.string.distance_from', this.distance) : '')
            .margin({ left: $r('app.float.sm_padding_margin') })
            .fontSize($r('app.float.small_font_size'))
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        }
        .width(CommonConstants.FULL_PERCENT)

        Row({ space: CommonConstants.SPACE_8 }) {
          Button($r('app.string.routes'))
            .layoutWeight(1)
            .height($r('app.float.location_img_size'))
            .onClick(() => this.clickAction(ModalActionType.ROUTE))
          Image($r('app.media.ic_navigation'))
            .height($r('app.float.location_img_size'))
            .aspectRatio(1)
            .onClick(() => this.clickAction(ModalActionType.NAVIGATION))
        }
      }
      .height($r('app.float.detail_info_height'))
      .padding({
        top: $r('app.float.md_padding_margin'),
        bottom: $r('app.float.md_padding_margin'),
        left: $r('app.float.lg_padding_margin'),
        right: $r('app.float.lg_padding_margin')
      })
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    }
    .borderRadius({
      topLeft: $r('app.float.border_radius_xxl'),
      topRight: $r('app.float.border_radius_xxl'),
      bottomLeft: new BreakpointType<Length>({
        sm: 0,
        md: $r('app.float.border_radius_xxl'),
        lg: $r('app.float.border_radius_xxl')
      }).getValue(this.currentBreakpoint),
      bottomRight: new BreakpointType<Length>({
        sm: 0,
        md: $r('app.float.border_radius_xxl'),
        lg: $r('app.float.border_radius_xxl')
      }).getValue(this.currentBreakpoint)
    })
    .clip(true)
    .animation({ curve: this.interpolatingCurve })
    .opacity(this.showDetail ? 1 : 0)
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .height(this.showDetail ? this.detailSheetHeight : 0)
    .width(this.currentBreakpoint === BreakpointTypeEnum.SM ? '100%' : Const.MODAL_MAX_WIDTH)
    .shadow({ radius: $r('app.float.md_border_radius'), color: $r('app.color.shadow_color'), offsetY: 8 })
    .margin({
      bottom: new BreakpointType<Length>({
        sm: 0,
        md: $r('app.float.xl_padding_margin'),
        lg: (AppStorage.get('naviIndicatorHeight') as number)
      }).getValue(this.currentBreakpoint),
      left: this.currentBreakpoint === BreakpointTypeEnum.SM ? 0 : this.positionX
    })
    .gesture(
      GestureGroup(GestureMode.Parallel,
        SwipeGesture({ direction: SwipeDirection.Vertical })
          .onAction((event: GestureEvent) => {
            animateTo({
              curve: this.interpolatingCurve
            }, () => {
              if (event.speed > 1000) {
                if (event.angle < 0 && this.detailSheetHeight < this.detailSheetMaxHeight) {
                  // Swipe up.
                  this.detailSheetHeight = this.detailSheetMaxHeight;

                } else {
                  // Swipe down.
                  if (this.detailSheetHeight > this.detailSheetMinHeight) {
                    this.detailSheetHeight = this.detailSheetMinHeight;
                  } else {
                    this.showDetail = false;
                  }
                }
              }
              Logger.info(TAG, `SwipeGesture speed: ${event.speed} , angle: ${event.angle}`)
            })
          }),
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart(() => {
            this.currentHeight = this.detailSheetHeight;
          })
          .onActionUpdate((event: GestureEvent) => {
            Logger.info(TAG, `PanGesture update:   ${JSON.stringify(event)}`);
            let offsetY: number = event.offsetY;
            animateTo({
              curve: this.interpolatingCurve
            }, () => {
              this.detailSheetHeight = this.currentHeight - offsetY;
            });
          })
          .onActionEnd((event: GestureEvent) => {
            Logger.info(TAG, `PanGesture end:   ${JSON.stringify(event)}`);
            let highThreshold: number = (this.detailSheetMaxHeight - this.detailSheetMinHeight) / 2;
            let lowThreshold: number = this.detailSheetMinHeight / 2;
            animateTo({
              curve: this.interpolatingCurve
            }, () => {
              if (this.detailSheetHeight > this.detailSheetMaxHeight) {
                this.detailSheetHeight = this.detailSheetMaxHeight;
              } else if (this.detailSheetHeight < this.detailSheetMinHeight) {
                if (this.detailSheetHeight < lowThreshold) {
                  this.showDetail = false;
                  this.detailSheetHeight = this.detailSheetMinHeight;
                } else {
                  this.detailSheetHeight = this.detailSheetMinHeight;
                }
              } else {
                let distance = Math.abs(this.detailSheetHeight - this.detailSheetMinHeight);
                this.detailSheetHeight =
                  distance > highThreshold ? this.detailSheetMaxHeight : this.detailSheetMinHeight;
              }
            })
          })
      )
    )
  }
}