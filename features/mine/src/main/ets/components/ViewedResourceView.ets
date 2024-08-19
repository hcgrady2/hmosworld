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
export struct ViewedResourceView {
  @State userModel: UserModel = UserModel.getInstance();
  @State loadingViewedStatus: LoadingStatus = LoadingStatus.OFF;
  innerScroller?: Scroller;
  outerScroller?: Scroller;
  @State viewedDataSource: LazyDataSource<LearningResource> = this.userModel.viewedDataSource;

  aboutToAppear() {
    this.loadViewedData();
  }

  loadViewedData() {
    this.loadingViewedStatus = LoadingStatus.LOADING;
    this.userModel.getViewedResources().then(() => {
      this.loadingViewedStatus = LoadingStatus.SUCCESS;
    }).catch(() => {
      this.loadingViewedStatus = LoadingStatus.FAILED;
    });
  }

  build() {
    if (this.loadingViewedStatus === LoadingStatus.LOADING) {
      LoadingView()
    } else if (this.loadingViewedStatus === LoadingStatus.FAILED) {
      LoadingFailedView(() => {
        this.loadViewedData();
      })
    } else if (this.viewedDataSource.totalCount() === 0) {
      NoneContentView($r('app.media.ic_browse_no'), $r('app.string.to_view'))
    } else {
      ResourceListView({
        resDataSource: this.viewedDataSource,
        scrollerForScroll: this.outerScroller,
        scrollerForList: this.innerScroller
      })
    }
  }
}