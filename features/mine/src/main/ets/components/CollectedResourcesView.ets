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

import { LoadingFailedView, NoneContentView } from '@ohos/uicomponents';
import { LazyDataSource, LoadingStatus } from '@ohos/utils';
import { LearningResource } from '../model/LearningResource';
import { UserModel } from '../model/UserModel';
import { LoadingView } from '../views/LoadingView';
import { ResourceListView } from './ResourceListView';

@Component
export struct CollectedResourceView {
  @State userModel: UserModel = UserModel.getInstance();
  @State loadingCollectedStatus: LoadingStatus = LoadingStatus.OFF;
  innerScroller?: Scroller;
  outerScroller?: Scroller;
  @State collectedDataSource: LazyDataSource<LearningResource> = this.userModel.collectedDataSource;

  aboutToAppear() {
    this.loadCollected();
  }

  loadCollected() {
    this.loadingCollectedStatus = LoadingStatus.LOADING;
    this.userModel.getCollectedResources().then(() => {
      this.loadingCollectedStatus = LoadingStatus.SUCCESS;
    }).catch(() => {
      this.loadingCollectedStatus = LoadingStatus.FAILED;
    });
  }

  build() {
    if (this.loadingCollectedStatus === LoadingStatus.LOADING) {
      LoadingView()
    } else if (this.loadingCollectedStatus === LoadingStatus.FAILED) {
      LoadingFailedView(() => {
        this.loadCollected();
      })
    } else if (this.collectedDataSource.totalCount() === 0) {
      NoneContentView($r('app.media.ic_empty_collected'), $r('app.string.to_collected'))
    } else {
      ResourceListView({
        resDataSource: this.collectedDataSource,
        scrollerForScroll: this.outerScroller,
        scrollerForList: this.innerScroller
      })
    }
  }
}