import { CommonConstants } from '@ohos/utils';

@Builder
export function TagLabelCard(text: string, color: string) {
  Text(text)
    .fontSize($r('app.float.xs_font_size'))
    .fontColor('#' + color)
    .textAlign(TextAlign.Center)
    .fontWeight(FontWeight.Medium)
    .fontFamily(CommonConstants.HARMONY_HEITI_MEDIUM_FONT_FAMILY)
    .borderRadius($r('app.float.xs_border_radius'))
    .backgroundColor('#1A' + color)
    .padding({
      left: $r('app.float.sm_padding_margin'),
      right: $r('app.float.sm_padding_margin'),
      top: $r('app.float.xxs_padding_margin'),
     bottom: $r('app.float.xxs_padding_margin')
    })
}