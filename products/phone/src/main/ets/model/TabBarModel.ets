/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export interface TabBarData {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  animationIcon: ResourceStr;
  defaultIcon: ResourceStr;
}

export enum TabBarType {
  DISCOVER = 0,
  LEARNING,
  CHALLENGE,
  ACTIVITY,
  MINE
}

export const TabsInfo: TabBarData[] = [
  {
    id: TabBarType.DISCOVER,
    title: $r('app.string.tab_discover'),
    animationIcon: $r('app.media.ic_tab_explore'),
    activeIcon: $r('app.media.ic_tab_explore_on'),
    defaultIcon: $r('app.media.ic_tab_explore_off')
  },
  {
    id: TabBarType.LEARNING,
    title: $r('app.string.tab_learning'),
    animationIcon: $r('app.media.ic_tab_study'),
    activeIcon: $r('app.media.ic_tab_study_on'),
    defaultIcon: $r('app.media.ic_tab_study_off')
  },
  {
    id: TabBarType.CHALLENGE,
    title: $r('app.string.tab_challenge'),
    animationIcon: $r('app.media.ic_challenge_on'),
    activeIcon: $r('app.media.ic_challenge_on'),
    defaultIcon: $r('app.media.ic_challenge_off')
  },
  {
    id: TabBarType.ACTIVITY,
    title: $r('app.string.tab_activity'),
    animationIcon: $r('app.media.ic_tab_conference'),
    activeIcon: $r('app.media.ic_tab_conference_on'),
    defaultIcon: $r('app.media.ic_tab_conference_off')
  },
  {
    id: TabBarType.MINE,
    title: $r('app.string.tab_mine'),
    animationIcon: $r('app.media.ic_tab_mine'),
    activeIcon: $r('app.media.ic_tab_mine_on'),
    defaultIcon: $r('app.media.ic_tab_mine_off')
  }
]