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

import { ColumnEnum, OffsetEnum, SpanEnum, WebUtil } from '@ohos/utils';
import { TopNavigationView } from '@ohos/uicomponents';
import { ChallengeConstants } from '../constants/ChallengeConstants';

const TAG = '[ChallengeDetailPage]';

@Component
export struct ChallengeDetailView {
  @Consume('appPathStack') appPathStack: NavPathStack;

  onBackPress(): boolean {
    let webview = WebUtil.getController(WebUtil.WebUrls.ACTIVITY_URL);
    if (webview?.accessBackward()) {
      webview.backward();
      return true;
    }
    return false;
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: $r('app.string.code_lab_challenge'),
          onBackClick: () => {
            const isBack: boolean = this.onBackPress();
            if (!isBack) {
              this.appPathStack.pop();
            }
          }
        })
        GridRow({
          columns: {
            xs: ColumnEnum.SM,
            sm: ColumnEnum.SM,
            md: ColumnEnum.MD,
            lg: ColumnEnum.LG
          },
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
            span: {
              xs: SpanEnum.SM,
              sm: SpanEnum.SM,
              md: SpanEnum.MD,
              lg: SpanEnum.LG
            },
            offset: {
              xs: OffsetEnum.SM,
              sm: OffsetEnum.SM,
              md: OffsetEnum.MD,
              lg: OffsetEnum.LG
            }
          }) {
            NodeContainer(WebUtil.getNWeb(WebUtil.WebUrls.CHALLENGE_URL))
              .width(ChallengeConstants.FULL_PERCENT)
              .height(ChallengeConstants.FULL_PERCENT)
          }
        }
      }
      .padding({ top: AppStorage.get<number>('statusBarHeight') })
      .width(ChallengeConstants.FULL_PERCENT)
      .height(ChallengeConstants.FULL_PERCENT)

    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.onBackPress();
    })
  }
}

@Builder
export function ChallengeDetailViewBuilder() {
  ChallengeDetailView();
}