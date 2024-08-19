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

import { common, Permissions, Want } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { MapComponent, mapCommon, map, navi } from '@kit.MapKit';
import { AudioPlayerService, AudioPlayerStatus } from '@ohos/audioplayer';
import { BreakpointTypeEnum, CommonConstants, CommonUtil, Logger, PermissionUtil } from '@ohos/utils';
import ZonesItem from '../model/ZonesItem';
import ZonesModel, { TravelModeType } from '../model/ZonesModel';
import { RouteActionType, RoutesSheet } from '../components/RoutesSheet';
import { ModalActionType, ZoneDetailModal } from '../components/ZoneDetailModal';

const TAG: string = '[MapView]';

@Component
export struct MapView {
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  @Provide('positionX') positionX: number = 24;
  private pointIds: string[] = [];
  permissions: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
  zonesList: ZonesItem[] = ZonesModel.getZonesList();
  currentSheetHeight: number = 0;
  requestInfo: geoLocationManager.LocationRequest = {
    'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
    'timeInterval': 0,
    'distanceInterval': 0,
    'maxAccuracy': 0
  };
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @StorageProp('currentBreakpoint') @Watch('handleBreakpointChange') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Provide('introductionData') selectedZone: ZonesItem = this.zonesList[0];
  currentLocation: mapCommon.LatLng = this.selectedZone.location;
  @State detailSheetHeight: number = 0;
  @State distance: string = '';
  @State showRoutes: boolean = false;
  @State @Watch('sheetVisiblyChange') showSheet: boolean = false;
  @State showDetail: boolean = false
  @State routePaths: Array<navi.Route> = [];
  @State selectedMode: number = 0;
  @State selectedRoute: number = 0;

  async aboutToAppear() {
    this.initMapOptions();
    PermissionUtil.requestPermissions(this.permissions);
  }

  aboutToDisappear(): void {
    if (canIUse('SystemCapability.Map.Core')) {
      this.mapController?.off('mapLoad', () => {
        Logger.info(TAG, `off-mapLoad`);
      });
      this.mapController?.off('mapClick', () => {
        Logger.info(TAG, `off-mapClick`);
      });
      this.mapController?.off('pointAnnotationClick', () => {
        Logger.info(TAG, `off-pointAnnotationClick`);
      });
    }
  }

  handleBreakpointChange() {
    if (this.currentBreakpoint !== BreakpointTypeEnum.SM && this.showRoutes) {
      this.showSheet = true;
      this.showRoutes = false;
    } else if (this.currentBreakpoint === BreakpointTypeEnum.SM && this.showSheet) {
      this.showRoutes = true;
      this.showSheet = false;
    }
  }

  sheetVisiblyChange() {
    Logger.info(TAG, 'sheetVisiblyChange showSheet:' + this.showSheet + '   showRoutes:' + this.showRoutes);
    if ((this.showSheet || this.showRoutes) && !(this.showRoutes && this.showSheet)) {
      this.currentSheetHeight = this.detailSheetHeight;
      this.detailSheetHeight = 320 - this.naviIndicatorHeight - 56;
    }
    if (!this.showSheet && !this.showRoutes) {
      this.detailSheetHeight = this.currentSheetHeight;
      this.redrawScenes();
    }
  }

  initMapOptions(): void {
    let target: mapCommon.LatLng = {
      latitude: 22.880878379924344,
      longitude: 113.88852986984118
    };
    let cameraPosition: mapCommon.CameraPosition = {
      target: target,
      zoom: 16,
    };
    this.mapOptions = {
      position: cameraPosition,
      scaleControlsEnabled: true
    };
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        if (canIUse('SystemCapability.Map.Core')) {
          this.mapController.setBuildingEnabled(true);
          this.mapController.setDayNightMode(mapCommon.DayNightMode.AUTO);
          this.mapController.setMyLocationStyle({ icon: $r('app.media.ic_me') });
          this.drawBuilding();

          this.mapController.on('mapLoad', async () => {
            Logger.info(TAG, `on-mapLoad`);
            const hasPermissions = await PermissionUtil.checkPermissions(this.permissions);
            if (!hasPermissions) {
              PermissionUtil.requestPermissions(this.permissions, () => {
                this.setMyLocationControl()
              });
            } else {
              this.setMyLocationControl();
            }
          })
          this.mapController.setMinZoom(2);
          this.mapController.setMaxZoom(18);

          this.mapController.on('mapClick', (position) => {
            Logger.info(TAG, `on-mapClick position = ${JSON.stringify(position)}`);
          });

          this.mapController.on('pointAnnotationClick', (pointAnnotation: map.PointAnnotation) => {
            let index: number = this.pointIds.indexOf(pointAnnotation.getId());
            this.showDetail = true;
            if (AppStorage.get('audioPlayerStatus') !== AudioPlayerStatus.IDLE) {
              AudioPlayerService.getInstance().stop();
            }
            if (index >= 0) {
              let zone: ZonesItem = this.zonesList[index % this.zonesList.length];
              let cameraPosition: mapCommon.CameraPosition = {
                target: zone.location,
                zoom: 15
              };
              map.newCameraPosition(cameraPosition);
              if (zone.id !== this.selectedZone.id || zone.id === this.zonesList[0].id) {
                this.selectedZone = zone;
                if (this.showRoutes) {
                  this.showRoutes = false;
                  this.showSheet = false;
                  this.routePaths = [];
                  this.redrawScenes();
                }
                this.getDistances();
              }
            }
            Logger.info(TAG, `on-PointAnnotationClick position = ${JSON.stringify(pointAnnotation)}`);
          });
        }
      }
    };
  }

  setMyLocationControl() {
    if (canIUse('SystemCapability.Map.Core')) {
      this.mapController?.setMyLocationStyle({ icon: $r('app.media.ic_me') });
      this.mapController?.setMyLocationEnabled(true);
      this.mapController?.setMyLocationControlsEnabled(true);
    }
  }

  startNavigation() {
    if (canIUse('SystemCapability.Map.Core')) {
      let petalMapWant: Want = {
        bundleName: 'com.huawei.hmos.maps.app',
        uri: 'maps://navigation',
        parameters: {
          linkSource: 'com.huawei.hmos.world',
          destinationLatitude: this.selectedZone.location.latitude,
          destinationLongitude: this.selectedZone.location.longitude,
          destinationName: this.selectedZone.title,
          originName: '我的位置',
          originLatitude: this.currentLocation.latitude,
          originLongitude: this.currentLocation.longitude,
          vehicleType: this.selectedMode,
        }
      }
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(petalMapWant);
    }
  }

  async drawBuilding() {
    if (this.mapController) {
      let length: number = this.zonesList.length;
      for (let i = 0; i < length; i++) {
        let zoneItem: ZonesItem = this.zonesList[i];
        if (canIUse('SystemCapability.Map.Core')) {
          let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
            position: zoneItem.location,
            repeatable: true,
            collisionRule: mapCommon.CollisionRule.NAME,
            titles: [{
              content: zoneItem.title,
              color: zoneItem.titleColor,
              fontSize: 12,
              strokeColor: 0xFFFFFFFF,
              strokeWidth: 2,
              fontStyle: mapCommon.FontStyle.BOLD
            }
            ],
            icon: zoneItem.icon,
            showIcon: true,
            forceVisible: false,
            minZoom: (i === 0 ? 2 : 14),
            maxZoom: 18,
            visible: true,
            zIndex: 5
          };
          let pointAnnotation = await this.mapController.addPointAnnotation(pointAnnotationOptions);
          this.pointIds.push(pointAnnotation.getId());
        }
      }
    }
  }

  async drawPaths() {
    if (canIUse('SystemCapability.Map.Core')) {
      try {
        let train2List: Array<mapCommon.LatLng> = (this.showRoutes || this.showSheet) ?
          this.routePaths[this.selectedRoute].overviewPolyline as Array<mapCommon.LatLng> : [];
        let points: Array<mapCommon.LatLng> = [train2List[0], train2List[train2List.length-1]];
        let icons: Resource[] = [$r('app.media.ic_travel_end'), $r('app.media.ic_end_point')];
        for (let i = 0; i < points.length; i++) {
          let markOption: mapCommon.MarkerOptions = {
            position: points[i],
            icon: icons[i],
            visible: true,
            zIndex: 12 + i
          };
          await this.mapController?.addMarker(markOption);
        }
        let polylineOption: mapCommon.MapPolylineOptions = {
          points: train2List,
          clickable: true,
          color: 0xff0C801F,
          startCap: mapCommon.CapStyle.ROUND,
          endCap: mapCommon.CapStyle.ROUND,
          geodesic: true,
          jointType: mapCommon.JointType.ROUND,
          visible: true,
          zIndex: 9,
          width: 32,
          gradient: false
        };
        await this.mapController?.addPolyline(polylineOption);
        polylineOption.color = 0xff65BB5C;
        polylineOption.zIndex = 10;
        polylineOption.width = 26;
        polylineOption.customTexture = $r('app.media.ic_arrow_right');
        await this.mapController?.addPolyline(polylineOption);
        Logger.info(TAG, 'draw success');
      } catch (error) {
        Logger.error(TAG, 'catch the error: ' + JSON.stringify(error));
      }
    }
  }

  getDistances() {
    this.distance = '';
    if (canIUse('SystemCapability.Map.Core')) {
      try {
        geoLocationManager.getCurrentLocation(this.requestInfo)
          .then(async (location: geoLocationManager.Location) => {
            Logger.info(TAG, 'current location: ' + JSON.stringify(location));
            let mapLocation: mapCommon.LatLng =
              await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, {
                latitude: location.latitude,
                longitude: location.longitude
              });
            this.currentLocation = mapLocation;
            let distance: number = map.calculateDistance(mapLocation, this.selectedZone.location);
            this.distance = CommonUtil.transDistanceWithUnit(distance);
          })
          .catch((error: BusinessError) => {
            if (error.code === 201) {
              promptAction.showToast({
                message: $r('app.string.manually_setting_permissions')
              });
            }
            Logger.error(TAG, 'promise, getCurrentLocation: error=' + JSON.stringify(error));
          });
      } catch (err) {
        Logger.error(TAG, 'errCode:' + (err as BusinessError).code + ',errMessage:' + (err as BusinessError).message);
      }
    }
  }

  async getMapRoutes() {
    let params: navi.RouteParams = {
      origins: [this.distance.length > 7 ? {
        latitude: 22.874712,
        longitude: 113.880028
      } : this.currentLocation],
      destination: this.selectedZone.location,
      language: 'zh_CN'
    };
    if (canIUse('SystemCapability.Map.Core')) {
      try {
        let routeResult: navi.RouteResult | null = null;
        if (this.selectedMode === TravelModeType.DRIVING) {
          let drivingParam: navi.DrivingRouteParams = params as navi.DrivingRouteParams;
          drivingParam.alternatives = true;
          routeResult = await navi.getDrivingRoutes(drivingParam);
          Logger.info(TAG, 'getDrivingRoutes success result =' + JSON.stringify(routeResult));
        } else if (this.selectedMode === TravelModeType.CYCLING) {
          routeResult = await navi.getCyclingRoutes(params);
          Logger.info(TAG, 'getCyclingRoutes success result =' + JSON.stringify(routeResult));
        } else {
          routeResult = await navi.getWalkingRoutes(params);
          Logger.info(TAG, 'getWalkingRoutes success result =' + JSON.stringify(routeResult));
        }
        if (routeResult) {
          this.routePaths = routeResult.routes;
          this.selectedRoute = 0;
          this.redrawScenes();
        }
      } catch (err) {
        Logger.error(TAG, 'getRoutes fail err =' + JSON.stringify(err));
      }
    }
  }

  redrawScenes() {
    if (canIUse('SystemCapability.Map.Core')) {
      this.mapController?.clear();
      this.pointIds = [];
      this.drawBuilding();
      this.drawPaths();
    }
  }

  @Builder
  routesSheetBuilder() {
    Column() {
      RoutesSheet({
        showSheet: $showSheet,
        selectedZones: [this.selectedZone],
        routePaths: this.routePaths,
        selectedMode: $selectedMode,
        selectedRoute: $selectedRoute,
        clickAction: (type: RouteActionType) => {
          if (type === RouteActionType.MODE) {
            this.getMapRoutes()
          } else if (type === RouteActionType.ROUTE) {
            this.redrawScenes();
          } else {
            this.startNavigation();
          }
        }
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (canIUse('SystemCapability.Map.Core')) {
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
      }
      ZoneDetailModal({
        detailSheetHeight: $detailSheetHeight,
        showDetail: $showDetail,
        distance: this.distance,
        clickAction: (type: ModalActionType) => {
          if (type === ModalActionType.ROUTE) {
            if (this.currentBreakpoint === BreakpointTypeEnum.SM) {
              this.showRoutes = true;
            } else {
              this.showSheet = true;
            }
            this.selectedMode = 0;
            this.getMapRoutes();
          } else if (type === ModalActionType.NAVIGATION) {
            this.startNavigation();
          }
        }
      })
      RoutesSheet({
        showSheet: $showSheet,
        selectedZones: [this.selectedZone],
        routePaths: this.routePaths,
        selectedMode: $selectedMode,
        selectedRoute: $selectedRoute,
        clickAction: (type: RouteActionType) => {
          if (type === RouteActionType.MODE) {
            this.getMapRoutes()
          } else if (type === RouteActionType.ROUTE) {
            this.redrawScenes();
          } else {
            this.startNavigation();
          }
        }
      })
        .visibility(this.currentBreakpoint === BreakpointTypeEnum.SM ? Visibility.None :
          (this.showSheet ? Visibility.Visible : Visibility.Hidden))
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_back'))
      }
      .onClick(() => {
        this.showRoutes = false;
        this.showSheet = false;
        this.sheetVisiblyChange();
      })
      .position({
        x: 24,
        y: (AppStorage.get('statusBarHeight') as number) + 8
      })
      .visibility((this.showSheet || this.showRoutes) ? Visibility.Visible : Visibility.Hidden)
      .height($r('app.float.md_btn_height'))
      .aspectRatio(1)
      .shadow({
        radius: $r('app.float.md_border_radius'),
        color: $r('app.color.shadow_color'),
        offsetY: $r('app.float.sm_padding_margin')
      })
      .backgroundColor($r('sys.color.ohos_id_color_titlebar_bg'))
    }
    .bindSheet($$this.showRoutes, this.routesSheetBuilder(), {
      enableOutsideInteractive: true,
      height: 320,
      showClose: false,
      dragBar: false,
      maskColor: '#00000000',
      backgroundColor: $r('sys.color.ohos_id_color_panel_bg'),
      onAppear: () => {
        this.sheetVisiblyChange();
        Logger.info(TAG, 'BindSheet onAppear.');
      },
      onDisappear: () => {
        this.showRoutes = false;
        this.sheetVisiblyChange();
        Logger.info(TAG, 'BindSheet onDisappear.');
      }
    })
  }
}