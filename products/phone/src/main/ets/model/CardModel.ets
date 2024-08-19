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

export interface CardData {
  id: string;
  title: string;
  brief: string;
  type: string;
  headerImageUrl: string;
  webUrl: string;
  defaultImg: Resource;
}

export const CARD_LIST: CardData[] = [
  {
    id: '1000048',
    title: '端云一体化助力高效开发，孩子王拥抱元服务实现商业增长',
    brief: '端云一体化助力高效开发，孩子王拥抱元服务实现商业增长',
    type: 'feed',
    webUrl: 'https://developer.huawei.com/consumer/information/cn/stories/detail?id=5892120813864f808ce9970f623f3c82&contType=stories',
    headerImageUrl: 'https://appfile-cn.dbankcdn.com/FileServer/getFile/appAttach/011/111/111/0000000000011111111.20230809161421.28756667956877492359497031662855:50001231000000:0001:34DF002204318A33B52B938C22A90AE61B5794CE631EBD609B73BA3CE51FCDFF.jpg',
    defaultImg: $r('app.media.ic_card_item_1')
  },
  {
    id: '20000052',
    title: '手把手教你使用ArkTS中的canvas实现签名板功能',
    brief: 'canvas画布通常用于实现一些画板或者图表、表格之类的功能，来尝试一下吧！',
    type: 'article',
    webUrl: 'https://mp.weixin.qq.com/s/wDIM1MJEHwz9-WAf0Vv6mg',
    headerImageUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-uvna9/20000052.png?token=0363799f-9f54-4404-89b4-437242181597',
    defaultImg: $r('app.media.ic_card_item_2')
  },
  {
    id: '1000047',
    title: '程序员挑战72小时开发元服务',
    brief: '程序员挑战72小时开发元服务',
    type: 'feed',
    webUrl: 'https://developer.huawei.com/consumer/information/cn/stories/detail?id=62d35f54033b45e8a271c1608d3ac950&contType=stories',
    headerImageUrl: 'https://appfile-cn.dbankcdn.com/FileServer/getFile/appAttach/011/111/111/0000000000011111111.20230822112448.01097256115172501492946491935904:50001231000000:0001:A103E3307AAF06484B4025D3C907F5E7E08CB38AD1FE54D58A52CF78CE638FCB.jpg',
    defaultImg: $r('app.media.ic_card_item_3')
  },
  {
    id: '20000053',
    title: '使用canvas实现图表系列之折线图',
    brief: '结合canvas绘画知识，手把手带你实现一个折线图组件，使组件更加容易拓展，维护性更强！',
    type: 'article',
    webUrl: 'https://mp.weixin.qq.com/s/w0urn8NEjZB6JPWdDuu0aQ',
    headerImageUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-uvna9/20000053.png?token=ab94223a-8d72-452d-a5d4-8c03c1ba7141',
    defaultImg: $r('app.media.ic_card_item_4')
  },
  {
    id: '10000020',
    title: '华为应用市场2022年度安全隐私报告',
    brief: '随着网络和信息技术的不断演进与发展，移动互联网逐渐成为重要的沟通桥梁和生活服务平台。',
    type: 'feed',
    webUrl: 'https://developer.huawei.com/consumer/information/cn/news/detail?id=f2841f7bc36446889dd5dae5ec9c4960&contType=news',
    headerImageUrl: 'https://appfile-cn.dbankcdn.com/FileServer/getFile/appAttach/011/111/111/0000000000011111111.20230330144010.15421506420410947729544185673826:50001231000000:0001:38F899F5FDC054B2E2883C6AE9442EDF95F12A29D9C7C5CF70B95410555D8606.jpg',
    defaultImg: $r('app.media.ic_card_item_5')
  }
]

class FormData {
  card0?: CardData;
  card1?: CardData;
  card2?: CardData;
  card3?: CardData;
  card4?: CardData;
  image0: string = '';
  image1: string = '';
  image2: string = '';
  image3: string = '';
  image4: string = '';
}

export const FORM_DATA: FormData = {
  card0: CARD_LIST[0],
  card1: CARD_LIST[1],
  card2: CARD_LIST[2],
  card3: CARD_LIST[3],
  card4: CARD_LIST[4],
  image0: '',
  image1: '',
  image2: '',
  image3: '',
  image4: ''
};

export const PROXY_KEYS: string[] = ['card0', 'card1', 'card2', 'card3', 'card4', 'image0', 'image1', 'image2', 'image3', 'image4'];