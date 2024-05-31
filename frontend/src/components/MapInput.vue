<script setup lang="ts">
import { defineModel, ref, onMounted, watch } from 'vue';
import pin from '@/assets/pin.png';
import Feature from 'ol/Feature';
import Map from 'ol/Map';
import OSM from 'ol/source/OSM';
import { Tile as TileLayer, Vector as VectorLayer } from 'ol/layer';
import View from 'ol/View';
import { Point } from 'ol/geom';
import { Vector as VectorSource } from 'ol/source';
import {
  Pointer as PointerInteraction,
  defaults as defaultInteractions,
} from 'ol/interaction';
import { toLonLat, fromLonLat } from 'ol/proj';

const latitude = defineModel('latitude', { required: true })
const longitude = defineModel('longitude', { required: true })
const map = ref<any>(null);
const point = ref<any>(null);
const view = ref<any>(null);
const dragging = ref(false);
const id = ref(`id-${Math.random()}`);

watch(latitude, (newValue: any) => {
  point.value.setCoordinates(fromLonLat([Number(longitude.value), Number(newValue)]));
  if (!dragging.value) {
    //view.value.animate({center: fromLonLat(currentCoordinates())});
    view.value.setCenter(fromLonLat(currentCoordinates()));
  }
});

watch(longitude, (newValue: any) => {
  point.value.setCoordinates(fromLonLat([Number(newValue), Number(latitude.value)]));
  if (!dragging.value) {
    view.value.setCenter(fromLonLat(currentCoordinates()));
  }
});

class Drag extends PointerInteraction {
  private coordinate_: any;
  private cursor_: any;
  private feature_: any;
  private previousCursor_: any;

  constructor() {
    super({
      handleDownEvent: handleDownEvent,
      handleDragEvent: handleDragEvent,
      handleMoveEvent: handleMoveEvent,
      handleUpEvent: handleUpEvent,
    });

    this.coordinate_ = null;
    this.cursor_ = 'pointer';
    this.feature_ = null;
    this.previousCursor_ = undefined;
  }
}

function handleDownEvent(this: any, evt: any) {
  const map = evt.map;

  const feature = map.forEachFeatureAtPixel(evt.pixel, (feature: unknown) => {
    return feature;
  });

  if (feature) {
    this.coordinate_ = evt.coordinate;
    this.feature_ = feature;
    dragging.value = true;
  }

  return !!feature;
}

function handleDragEvent(this: any, evt: any) {
  const deltaX = evt.coordinate[0] - this.coordinate_[0];
  const deltaY = evt.coordinate[1] - this.coordinate_[1];

  const geometry = this.feature_.getGeometry();
  geometry.translate(deltaX, deltaY);

  this.coordinate_[0] = evt.coordinate[0];
  this.coordinate_[1] = evt.coordinate[1];

  const c = toLonLat(this.coordinate_);
  latitude.value = c[1];
  longitude.value = c[0];
}

function handleMoveEvent(this: any, evt: any) {
  if (this.cursor_) {
    const map = evt.map;
    const feature = map.forEachFeatureAtPixel(evt.pixel, (feature: unknown) => feature);
    const element = evt.map.getTargetElement();
    if (feature) {
      if (element.style.cursor != this.cursor_) {
        this.previousCursor_ = element.style.cursor;
        element.style.cursor = this.cursor_;
      }
    } else if (this.previousCursor_ !== undefined) {
      element.style.cursor = this.previousCursor_;
      this.previousCursor_ = undefined;
    }
  }
}

const currentCoordinates = (): [number, number] => {
  return [Number(longitude.value) || 0, Number(latitude.value) || 0];
}

function handleUpEvent(this: any) {
  this.coordinate_ = null;
  this.feature_ = null;
  dragging.value = false;
  return false;
}

onMounted(() => {
  point.value = new Point(fromLonLat(currentCoordinates()));
  view.value = new View({
    center: fromLonLat(currentCoordinates()),
    zoom: 5,
  });
  const pointFeature = new Feature(point.value);
  map.value = new Map({
    interactions: defaultInteractions().extend([new Drag()]),
    layers: [
      new TileLayer({
        source: new OSM(),
      }),
      new VectorLayer({
        source: new VectorSource({
          features: [pointFeature],
        }),
        style: {
          'icon-src': pin, //'https://as2.ftcdn.net/v2/jpg/03/29/26/39/1000_F_329263903_Oax03LQARwf34pbJn4rdcmQ2dgJMzo1D.jpg',
          'icon-opacity': 0.95,
          'icon-anchor': [0.2, 70],
          'icon-anchor-x-units': 'fraction',
          'icon-anchor-y-units': 'pixels',
          'icon-width': 30,
          'stroke-width': 3,
          'stroke-color': [255, 0, 0, 1],
          'fill-color': [0, 0, 255, 0.6],
        },
      }),
    ],
    target: id.value,
    view: view.value,
  });
});
</script>

<template>
  <div>
    <div :id="id" style="height: 500px; width: 100%; min-width: 500px;"/>
  </div>
</template>

<style scoped>
</style>
