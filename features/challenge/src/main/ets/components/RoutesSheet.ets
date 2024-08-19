/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { curves } from '@kit.ArkUI';
import { navi } from '@kit.MapKit';
import { BreakpointType, BreakpointTypeEnum, CommonConstants, Logger } from '@ohos/utils';
import ZonesItem from '../model/ZonesItem';
import { RouteNames, TravelMode, TravelModes } from '../model/ZonesModel';
import { ChallengeConstants as Const } from '../constants/ChallengeConstants';

export enum RouteActionType {
  MODE = 0,
  ROUTE,
  NAVIGATION
}

const TAG: string = '[RoutesSheet]';
const SHEET_HEIGHT: number = 320;

@Component
export struct RoutesSheet {
  interpolatingCurve: ICurve = curves.interpolatingSpring(0, 1, 328, 36);
  selectedZones: ZonesItem[] = [];
  currentHeight: number = 0;
  @Prop routePaths: Array<navi.Route> = [];
  @Link selectedMode: number;
  @Link selectedRoute: number;
  @Link showSheet: boolean;
  @Consume('positionX') positionX: number;
  @State sheetHeight: number = SHEET_HEIGHT;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  clickAction: Function = (type: RouteActionType) => {
  };

  build() {
    Column() {
      Column() {
        Row()
          .height($r('app.float.drag_bar_height'))
          .width($r('app.float.drag_bar_width'))
          .backgroundColor($r('sys.color.ohos_id_color_fourth'))
          .borderRadius($r('app.float.drag_bar_border_radius'))
      }
      .padding({
        top: $r('app.float.sm_padding_margin'),
        bottom: $r('app.float.xs_padding_margin')
      })
      .margin({ bottom: $r('app.float.sm_padding_margin') })
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))

      Row() {
        Image($r('app.media.ic_vel_line'))
          .width($r('app.float.line_icon_width'))
        Column() {
          Text($r('app.string.my_location'))
            .fontSize($r('app.float.challenge_title_size_sm'))
          Divider()
            .width(CommonConstants.FULL_PERCENT)
            .margin({ top: $r('app.float.line_margin'), bottom: $r('app.float.line_margin') })
          Text(this.selectedZones[0].title)
            .fontSize($r('app.float.challenge_title_size_sm'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: $r('app.float.md_padding_margin') })
        .layoutWeight(1)

        Image($r('app.media.ic_routes_plus'))
          .width($r('app.float.small_icon_size'))
          .fillColor($r('sys.color.ohos_id_color_subtab_text_off'))
          .margin({ left: $r('app.float.xl_padding_margin') })
        Image($r('app.media.ic_routes_conver'))
          .fillColor($r('sys.color.ohos_id_color_subtab_text_off'))
          .width($r('app.float.small_icon_size'))
          .margin({ left: $r('app.float.md_padding_margin') })
        Image($r('app.media.ic_routes_voice'))
          .fillColor($r('sys.color.ohos_id_color_subtab_text_off'))
          .width($r('app.float.small_icon_size'))
          .margin({ left: $r('app.float.md_padding_margin') })

      }
      .padding({ left: $r('app.float.lg_padding_margin'), right: $r('app.float.lg_padding_margin') })
      .height($r('app.float.route_bg_height'))
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .borderRadius($r('app.float.xl_border_radius'))

      Row({ space: CommonConstants.SPACE_8 }) {
        ForEach(TravelModes, (travelMode: TravelMode, index: number) => {
          Button() {
            Row() {
              Image(travelMode.tagIcon)
                .width($r('app.float.small_icon_size'))
                .aspectRatio(1)
                .visibility(this.selectedMode === index ? Visibility.Visible : Visibility.None)
                .margin({ right: $r('app.float.xs_padding_margin') })
              Text(travelMode.title)
                .fontSize($r('app.float.font_size_normal'))
                .fontColor(this.selectedMode === index ? $r('sys.color.ohos_id_color_text_primary_contrary') :
                $r('sys.color.ohos_id_color_text_primary'))
            }
          }
          .onClick(() => {
            this.selectedMode = index;
            this.clickAction(RouteActionType.MODE);
          })
          .backgroundColor(this.selectedMode === index ? $r('sys.color.ohos_id_color_focused_bg') :
          $r('sys.color.ohos_id_color_background'))
          .height($r('app.float.sm_btn_height'))
          .layoutWeight(1)
        })
      }
      .margin({ top: $r('app.float.md_padding_margin') })

      Row({ space: CommonConstants.SPACE_16 }) {
        ForEach(this.routePaths, (route: navi.Route, index: number) => {
          Column() {
            Text(RouteNames[index])
              .fontSize($r('app.float.small_font_size'))
              .fontColor(this.selectedRoute === index ? $r('sys.color.ohos_id_color_text_primary_activated') :
              $r('sys.color.ohos_fa_text_primary'))
              .lineHeight($r('app.float.challenge_title_size_sm'))
              .fontWeight(FontWeight.Bold)
            Text(route.steps[0].durationDescription)
              .fontSize($r('app.float.duration_font_size'))
              .fontColor(this.selectedRoute === index ? $r('sys.color.ohos_id_color_text_primary_activated') :
              $r('sys.color.ohos_fa_text_primary'))
              .lineHeight($r('app.float.navigation_title_size'))
              .fontWeight(FontWeight.Bold)
            Text(route.steps[0].distanceDescription)
              .fontSize($r('app.float.small_font_size'))
              .opacity(CommonConstants.SECOND_LEVEL_OPACITY)
              .fontColor(this.selectedRoute === index ? $r('sys.color.ohos_id_color_text_primary_activated') :
              $r('sys.color.ohos_fa_text_primary'))
              .lineHeight($r('app.float.challenge_title_size_sm'))
              .fontWeight(FontWeight.Medium)

          }
          .onClick(() => {
            this.selectedRoute = index;
            this.clickAction(RouteActionType.ROUTE);
          })
          .layoutWeight(1)
          .borderRadius($r('app.float.md_border_radius'))
          .shadow(this.selectedRoute === index ?
            { radius: $r('app.float.md_border_radius'), color: $r('app.color.shadow_color'), offsetY: 8 } : null)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.selectedRoute === index ? $r('sys.color.ohos_id_color_background') :
          $r('sys.color.ohos_id_color_panel_bg'))
          .padding({
            left: $r('app.float.sm_padding_margin'),
            top: $r('app.float.xs_padding_margin'),
            right: $r('app.float.sm_padding_margin'),
            bottom: $r('app.float.xs_padding_margin')
          })
        })
      }
      .visibility(this.routePaths.length > 0 ? Visibility.Visible : Visibility.None)
      .margin({ top: $r('app.float.lg_padding_margin'), bottom: $r('app.float.lg_padding_margin') })

      Row() {
        LoadingProgress()
          .height($r('app.float.page_icon_size'))
      }
      .visibility(this.routePaths.length === 0 ? Visibility.Visible : Visibility.None)
      .height($r('app.float.arrow_down_width'))
      .margin({ top: $r('app.float.lg_padding_margin'), bottom: $r('app.float.lg_padding_margin') })

      Blank()
      Button() {
        Row() {
          Image(TravelModes[this.selectedMode].tagIcon)
            .width($r('app.float.normal_icon_size'))
            .aspectRatio(1)
            .margin({ right: $r('app.float.ss_padding_margin') })
          Text($r('app.string.start_navi'))
            .fontSize($r('app.float.challenge_title_size_sm'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
        }
      }
      .onClick(() => this.clickAction(RouteActionType.NAVIGATION))
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.md_btn_height'))
      .margin({ bottom: $r('app.float.md_padding_margin') })
      .backgroundColor($r('sys.color.ohos_id_color_focused_bg'))
    }
    .animation({ curve: this.interpolatingCurve })
    .clip(true)
    .width(this.currentBreakpoint === BreakpointTypeEnum.SM ? CommonConstants.FULL_PERCENT : Const.MODAL_MAX_WIDTH)
    .height((this.showSheet || this.currentBreakpoint === BreakpointTypeEnum.SM) ? this.sheetHeight : 0)
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .shadow(this.currentBreakpoint === BreakpointTypeEnum.SM ? null :
      { radius: $r('app.float.md_border_radius'), color: $r('app.color.shadow_color'), offsetY: 8 })
    .padding({
      left: $r('app.float.lg_padding_margin'),
      right: $r('app.float.lg_padding_margin'),
      bottom: (this.currentBreakpoint === BreakpointTypeEnum.SM ? (this.naviIndicatorHeight + 16) :
      $r('app.float.lg_padding_margin'))
    })
    .margin({
      bottom: new BreakpointType<Length>({
        sm: 0,
        md: $r('app.float.xl_padding_margin'),
        lg: (AppStorage.get('naviIndicatorHeight') as number)
      }).getValue(this.currentBreakpoint),
      left: this.currentBreakpoint === BreakpointTypeEnum.SM ? 0 : this.positionX
    })
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
    .gesture(
      GestureGroup(GestureMode.Parallel,
        SwipeGesture({
          direction: this.currentBreakpoint === BreakpointTypeEnum.SM ? SwipeDirection.None : SwipeDirection.Vertical
        })
          .onAction((event: GestureEvent) => {
            animateTo({
              curve: this.interpolatingCurve
            }, () => {
              if (event.speed > 1000 && event.angle > 0) {
                // Swipe down.
                if (this.sheetHeight < SHEET_HEIGHT / 2) {
                  this.showSheet = false;
                }
                this.sheetHeight = SHEET_HEIGHT;
              }
              Logger.info(TAG, `SwipeGesture speed: ${event.speed} , angle: ${event.angle}`)
            })
          }),
        PanGesture({
          direction: this.currentBreakpoint === BreakpointTypeEnum.SM ? PanDirection.None : PanDirection.Vertical
        })
          .onActionStart(() => {
            this.currentHeight = this.sheetHeight;
          })
          .onActionUpdate((event: GestureEvent) => {
            Logger.info(TAG, `PanGesture update:   ${JSON.stringify(event)}`);
            let offsetY: number = event.offsetY;
            animateTo({
              curve: this.interpolatingCurve
            }, () => {
              this.sheetHeight = this.currentHeight - offsetY;
            });
          })
          .onActionEnd((event: GestureEvent) => {
            Logger.info(TAG, `PanGesture end:   ${JSON.stringify(event)}`);
            animateTo({
              curve: this.interpolatingCurve
            }, () => {
              if (this.sheetHeight < SHEET_HEIGHT / 2) {
                this.showSheet = false;
              }
              this.sheetHeight = SHEET_HEIGHT;
            })
          })
      )
    )
  }
}