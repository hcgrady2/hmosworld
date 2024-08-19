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

import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { webview } from '@kit.ArkWeb';
import { InteractiveAreaView } from '@ohos/uicomponents';
import {
  ContinueModel,
  BreakpointTypeEnum,
  CommonConstants,
  EventTypeEnum,
  ResourcesType,
  WindowUtil,
  WebUtil,
  ColumnEnum,
  SpanEnum,
  OffsetEnum,
  RouterNameEnum
} from '@ohos/utils';
import { LearningResource } from '../model/LearningResource';

const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
const TAG = '[ArticleDetailView]';

@Component
export struct ArticleDetailView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State webViewController: WebviewController = new webview.WebviewController();
  @State articleDetail: LearningResource = new LearningResource();
  @State isLarge: boolean = false;
  @State webKey: string = '';
  @State showInteractiveArea: boolean = true;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;

  onBackPressed(): boolean {
    let webController = WebUtil.getController(this.articleDetail.webUrl);
    if (webController?.accessBackward()) {
      webController.backward();
      return true;
    }
    return false;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_back'))
              .width($r('app.float.button_height'))
              .margin({ right: $r('app.float.lg_padding_margin') })
              .onClick(() => {
                ContinueModel.getInstance().resetContinue();
                this.appPathStack.pop();
              })
              .visibility(this.currentBreakpoint !== BreakpointTypeEnum.LG || this.isLarge ? Visibility.Visible :
              Visibility.None)

            Text(this.articleDetail.type === ResourcesType.FEED ? $r('app.string.feed') : $r('app.string.article'))
              .fontSize($r('app.float.nav_title_font_size'))
          }

          Image(this.isLarge ? $r('app.media.ic_reduce') : $r('app.media.ic_enlarge'))
            .fillColor($r('sys.color.ohos_id_color_foreground'))
            .height($r('app.float.enlarge_img_size'))
            .aspectRatio(1)
            .onClick(() => {
              if (this.isLarge) {
                ContinueModel.getInstance().resetContinue();
                this.appPathStack.pop();
              } else {
                ContinueModel.getInstance().setRouterName(RouterNameEnum.MINE_ARTICLE_VIEW);
                this.appPathStack.pushPathByName('MineArticleDetail',
                  new Object({ articleDetail: this.articleDetail, isLarge: true }));
              }
            })
            .visibility(this.currentBreakpoint === BreakpointTypeEnum.LG ? Visibility.Visible : Visibility.Hidden)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(this.isLarge ? {
          left: $r('app.float.xxl_padding_margin'),
          right: $r('app.float.xxl_padding_margin')
        } : {
          left: $r('app.float.md_padding_margin'),
          right: $r('app.float.md_padding_margin')
        })
        .height($r('app.float.tab_bar_height'))
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius({ topLeft: $r('app.float.large_border_radius'), topRight: $r('app.float.large_border_radius') })
        .backgroundColor($r('sys.color.ohos_id_color_background'))

        Stack({ alignContent: Alignment.Bottom }) {
          GridRow({
            columns: this.isLarge ? {
              xs: ColumnEnum.SM,
              sm: ColumnEnum.SM,
              md: ColumnEnum.MD,
              lg: ColumnEnum.LG
            } : 1,
            gutter: {
              x: {
                xs: $r('app.float.xxl_padding_margin'),
                sm: $r('app.float.xxl_padding_margin'),
                md: $r('app.float.md_padding_margin'),
                lg: $r('app.float.md_padding_margin')
              }
            },
            breakpoints: { reference: BreakpointsReference.ComponentSize }
          }) {
            GridCol({
              span: this.isLarge ? {
                xs: SpanEnum.SM,
                sm: SpanEnum.SM,
                md: SpanEnum.MD,
                lg: SpanEnum.LG
              } : 1,
              offset: this.isLarge ? {
                xs: OffsetEnum.SM,
                sm: OffsetEnum.SM,
                md: OffsetEnum.MD,
                lg: OffsetEnum.LG
              } : 0
            }) {
              NodeContainer(WebUtil.getNWeb(this.webKey))
            }
          }

          if (this.showInteractiveArea) {
            InteractiveAreaView({
              isLiked: this.articleDetail.isLiked,
              isCollected: this.articleDetail.isCollected,
              onCollected: () => {
                eventHub.emit(EventTypeEnum.COLLECTED, {
                  resourceId: this.articleDetail.id,
                  resourceType: this.articleDetail.type,
                  actionValue: !this.articleDetail.isCollected
                })
              },
              onLiked: () => {
                eventHub.emit(EventTypeEnum.LIKED, {
                  resourceId: this.articleDetail.id,
                  resourceType: this.articleDetail.type,
                  actionValue: !this.articleDetail.isLiked
                })
              }
            })
          }
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor(this.isLarge ? $r('sys.color.ohos_id_color_background') :
      $r('app.color.hmos_background_color_white'))
      .padding({ top: this.isLarge ? AppStorage.get<number>('statusBarHeight') : 0 })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ right: !this.isLarge ? $r('app.float.xxl_padding_margin') : 0 })
    .hideTitleBar(true)
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, object | boolean>;
      this.articleDetail = params.articleDetail as LearningResource;
      this.isLarge = params.isLarge as boolean;
      // Distinguish whether the pad is in full-screen mode.
      this.webKey = this.articleDetail.webUrl + (this.isLarge ? '~large' : '~small');
      WebUtil.createNWeb(this.webKey);

      WebUtil.setOnPageEndAction(this.webKey, () => {
        let webController = WebUtil.getController(this.articleDetail.webUrl);
        if (webController?.accessBackward()) {
          this.showInteractiveArea = false;
        } else {
          this.showInteractiveArea = true;
        }
      });
    })
    .onShown(() => {
      if (this.isLarge) {
        WindowUtil.updateStatusBarColor(getContext(this),
          AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      }
    })
    .onHidden(() => {
      if (this.isLarge) {
        WindowUtil.updateStatusBarColor(getContext(this), true);
      }
    })
    .backgroundColor($r('app.color.hmos_background_color_white'))
    .onBackPressed(() => this.onBackPressed())
  }
}

@Builder
export function MineArticleDetailBuilder(params: object): void {
  ArticleDetailView(params);
}