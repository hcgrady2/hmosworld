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

// search history
import { BreakpointType, BreakpointTypeEnum, CommonConstants } from '@ohos/utils';

const HISTORY_LABEL_HEIGHT = 28;
const HISTORY_LABEL_WIDTH_SM = 160;
const HISTORY_LABEL_WIDTH_MD = 228;
const HISTORY_LABEL_WIDTH_LG = 403;

@Component
export struct SearchHistory {
  @Prop data: string[];
  @Prop title: Resource;
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;
  onClickIcon?: () => void;
  onClickText: (text: string) => void = () => {
  };

  build() {
    Column() {
      quickSearchGroupHeader(this.title, () => this.onClickIcon?.())
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.data, (item: string) => {
          Button(item) {
            Text(item)
              .maxLines(1)
              .fontSize($r('app.float.normal_text_size1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.sm_padding_margin'), right: $r('app.float.sm_padding_margin') })
          }
          .type(ButtonType.Capsule)
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .margin({
            right: new BreakpointType({
              sm: $r('app.float.sm_padding_margin'),
              md: $r('app.float.md_padding_margin'),
              lg: $r('app.float.md_padding_margin')
            }).getValue(this.currentBreakpoint),
            bottom: $r('app.float.xs_padding_margin')
          })
          .height(HISTORY_LABEL_HEIGHT)
          .constraintSize({
            minWidth: 0,
            maxWidth: new BreakpointType({
              sm: HISTORY_LABEL_WIDTH_SM,
              md: HISTORY_LABEL_WIDTH_MD,
              lg: HISTORY_LABEL_WIDTH_LG
            }).getValue(this.currentBreakpoint)
          })
          .onClick(() => this.onClickText(item))
        })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}

// common list item header
@Builder
function quickSearchGroupHeader(groupName: Resource, onClickIcon?: () => void) {
  Row() {
    Text(groupName)
      .fontSize($r('app.float.default_font_size'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
    if (onClickIcon) {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontColor([$r('sys.color.ohos_id_color_fourth')])
        .fontSize($r('app.float.normal_img_size'))
        .onClick(() => onClickIcon())
    }
  }
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.SpaceBetween)
  .height($r('app.float.search_group_height'))
  .width(CommonConstants.FULL_PERCENT)
}