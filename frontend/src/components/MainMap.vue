<script setup lang="ts">
import { ref, onMounted } from 'vue';
import pin from '@/assets/pin.png';
import Feature from 'ol/Feature';
import Map from 'ol/Map';
import OSM from 'ol/source/OSM';
import { Tile as TileLayer, Vector as VectorLayer } from 'ol/layer';
import View from 'ol/View';
import { Point } from 'ol/geom';
import { Vector as VectorSource } from 'ol/source';
import { fromLonLat, toLonLat } from 'ol/proj';
import { getBottomLeft, getTopRight } from 'ol/extent';

const emit = defineEmits(['positionChanged']);

const map = ref<any>(null);
const point = ref<any>(null);
const view = ref<any>(null);
const id = ref(`id-${Math.random()}`);

function wrapLon(value: number): number {
  const worlds = Math.floor((value + 180) / 360);
  return value - worlds * 360;
}

function onMoveEnd(evt: any) {
  const map = evt.map;
  const extent = map.getView().calculateExtent(map.getSize());
  const bottomLeft = toLonLat(getBottomLeft(extent));
  const topRight = toLonLat(getTopRight(extent));
  const left = wrapLon(bottomLeft[0]);
  const bottom = bottomLeft[1];
  const right = wrapLon(topRight[0]);
  const top = topRight[1];
  emit('positionChanged', {
    left,
    bottom,
    right,
    top,
    centerX: left + (right - left) / 2, // TODO: fix if right < left 
    centerY: bottom + (top - bottom) / 2,
  });
}

onMounted(() => {
  const cords = [0, 0];

  point.value = new Point(fromLonLat(cords));
  view.value = new View({
    center: fromLonLat(cords),
    zoom: 5,
  });
  const pointFeature = new Feature(point.value);
  map.value = new Map({
    layers: [
      new TileLayer({
        source: new OSM(),
      }),
      new VectorLayer({
        source: new VectorSource({
          features: [pointFeature],
        }),
        style: {
          'icon-src': pin, 
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

  map.value.on('moveend', onMoveEnd);
});
</script>

<template>
  <div style="width: 100%; height: 100%;">
    <div :id="id" style="min-height: 500px; height: 100%; width: 100%; min-width: 500px;"/>
  </div>
</template>

<style scoped>
</style>
