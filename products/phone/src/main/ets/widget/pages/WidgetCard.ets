/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

let storage = new LocalStorage();

@Entry(storage)
@Component
struct WidgetCard {
  readonly FULL_PERCENT: string = '100%';
  @LocalStorageProp('card0') cardData0: ICardItem = new ICardItem();
  @LocalStorageProp('card1') cardData1: ICardItem = new ICardItem();
  @LocalStorageProp('card2') cardData2: ICardItem = new ICardItem();
  @LocalStorageProp('card3') cardData3: ICardItem = new ICardItem();
  @LocalStorageProp('card4') cardData4: ICardItem = new ICardItem();
  @LocalStorageProp('image0') image0: string = '';
  @LocalStorageProp('image1') image1: string = '';
  @LocalStorageProp('image2') image2: string = '';
  @LocalStorageProp('image3') image3: string = '';
  @LocalStorageProp('image4') image4: string = '';

  build() {
    Column() {
      Row() {
        Text($r('app.string.popular_findings'))
          .fontSize($r('app.float.title_text_size'))
          .fontColor($r('app.color.card_title'))
          .lineHeight($r('app.float.title_line_height'))
          .layoutWeight(1)
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi-Medium')
      }
      .padding({
        top: $r('app.float.lg_padding_margin'),
        bottom: $r('app.float.sm_padding_margin'),
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin')
      })
      .backgroundColor($r('app.color.card_title_bg'))

      List() {
        ListItem() {
          CardItem({
            itemData: this.cardData0,
            imageFd: this.image0
          })
        }

        ListItem() {
          CardItem({
            itemData: this.cardData1,
            imageFd: this.image1
          })
        }

        ListItem() {
          CardItem({
            itemData: this.cardData2,
            imageFd: this.image2
          })
        }

        ListItem() {
          CardItem({
            itemData: this.cardData3,
            imageFd: this.image3
          })
        }

        ListItem() {
          CardItem({
            itemData: this.cardData4,
            imageFd: this.image4
          })
        }
      }
      .listDirection(Axis.Vertical) // 排列方向
      .scrollBar(BarState.Off)
      .divider({ strokeWidth: 1, color: $r('app.color.tab_border_color'), }) // 每行之间的分界线
      .backgroundColor($r('app.color.card_bg'))
      .padding({
        bottom: $r('app.float.ss_padding_margin'),
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin')
      })
    }
    .width(this.FULL_PERCENT)
    .height(this.FULL_PERCENT)
  }
}

@Component
struct CardItem {
  readonly ACTION_TYPE: string = 'router';
  readonly ABILITY_NAME: string = 'EntryAbility';
  readonly FULL_WIDTH_PERCENT: string = '100%';
  @Prop itemData: ICardItem;
  @Prop imageFd: string;

  getImage() {
    if (this.imageFd != '') {
      return 'memory://' + this.imageFd;
    } else {
      return this.itemData.defaultImg || $r('app.media.ic_card_item_default');
    }
  }

  build() {
    Row() {
      Column() {
        Text(this.itemData.title)
          .fontSize($r('app.float.font_size'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(Color.Black)
          .maxLines(1)
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi-Medium')
        Text(this.itemData.brief)
          .fontSize($r('app.float.small_text_size'))
          .margin({ top: $r('app.float.tab_title_margin') })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('app.color.tab_bar_color'))
          .maxLines(1)
          .fontWeight(FontWeight.Normal)
          .fontFamily('HarmonyHeiTi')
      }
      .padding({ right: $r('app.float.xxl_padding_margin') })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.End)
      .layoutWeight(1)

      Image(this.getImage())
        .width($r('app.float.card_img_size'))
        .height($r('app.float.card_img_size'))
        .borderRadius($r('app.float.sm_border_radius'))
    }
    .alignItems(VerticalAlign.Center)
    .width(this.FULL_WIDTH_PERCENT)
    .padding({ top: $r('app.float.card_item_padding'), bottom: $r('app.float.card_item_padding') })
    .onClick(() => {
      postCardAction(this, {
        'action': this.ACTION_TYPE,
        'abilityName': this.ABILITY_NAME,
        'params': {
          'articleId': this.itemData.id,
          'type': this.itemData.type,
          'webUrl': this.itemData.webUrl,
        }
      });
    })
  }
}

@Observed
export class ICardItem {
  id: string = '';
  title: string = '';
  brief: string = '';
  type: string = '';
  webUrl: string = '';
  headerImageUrl: string = '';
  defaultImg?: Resource
}