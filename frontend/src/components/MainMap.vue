<script setup lang="ts">
import { ref, shallowRef, onMounted, watch } from 'vue';
import pin from '@/assets/pin.png';
import Feature from 'ol/Feature';
import Map from 'ol/Map';
import OSM from 'ol/source/OSM';
import { Tile as TileLayer, Vector as VectorLayer } from 'ol/layer';
import View from 'ol/View';
import { Point } from 'ol/geom';
import { Vector as VectorSource } from 'ol/source';
import { Style, Icon, Circle as CircleStyle, Fill, Stroke, Text } from 'ol/style';
import { fromLonLat, toLonLat } from 'ol/proj';
import { getBottomLeft, getTopRight } from 'ol/extent';
import type MapEvent from 'ol/MapEvent';
import type { MapPin } from './ApiProvider';

const props = defineProps<{
  pins?: MapPin[];
}>();

const emit = defineEmits<{
  (e: 'positionChanged', payload: {
    left: number;
    bottom: number;
    right: number;
    top: number;
    centerX: number;
    centerY: number;
  }): void;
}>();

const map = shallowRef<Map | null>(null);
const view = shallowRef<View | null>(null);
const vectorSource = shallowRef<VectorSource>(new VectorSource());
const id = ref(`id-${Math.random()}`);

function wrapLon(value: number): number {
  const worlds = Math.floor((value + 180) / 360);
  return value - worlds * 360;
}

function onMoveEnd(evt: MapEvent) {
  const mapInstance = evt.map;
  const size = mapInstance.getSize();
  if (!size) return;

  const extent = mapInstance.getView().calculateExtent(size);
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
    centerX: left + (right - left) / 2,
    centerY: bottom + (top - bottom) / 2,
  });
}

function renderPins(pinsList: MapPin[]) {
  if (!vectorSource.value) return;
  vectorSource.value.clear();

  const features = pinsList.map((pinItem) => {
    const geom = new Point(fromLonLat([pinItem.location.longitude, pinItem.location.latitude]));
    const feature = new Feature({ geometry: geom });

    if (pinItem.type === 'single_pin') {
      feature.setStyle(
        new Style({
          image: new Icon({
            src: pin,
            opacity: 0.95,
            anchor: [0.5, 1],
            scale: 0.85,
          }),
        })
      );
    } else {
      feature.setStyle(
        new Style({
          image: new CircleStyle({
            radius: 20,
            fill: new Fill({ color: '#ff5722' }),
            stroke: new Stroke({ color: '#ffffff', width: 3 }),
          }),
          text: new Text({
            text: String(pinItem.numberOfPins),
            font: 'bold 13px sans-serif',
            fill: new Fill({ color: '#ffffff' }),
            textAlign: 'center',
            textBaseline: 'middle',
          }),
        })
      );
    }
    return feature;
  });

  vectorSource.value.addFeatures(features);
}

watch(
  () => props.pins,
  (newPins) => {
    if (newPins) {
      renderPins(newPins);
    }
  },
  { deep: true }
);

onMounted(() => {
  const cords = [21.01, 52.23]; // Default to Warsaw

  view.value = new View({
    center: fromLonLat(cords),
    zoom: 6,
  });

  map.value = new Map({
    layers: [
      new TileLayer({
        source: new OSM(),
      }),
      new VectorLayer({
        source: vectorSource.value,
      }),
    ],
    target: id.value,
    view: view.value,
  });

  map.value.on('moveend', onMoveEnd);

  if (props.pins && props.pins.length > 0) {
    renderPins(props.pins);
  }
});
</script>

<template>
  <div style="width: 100%; height: 100%;">
    <div :id="id" style="min-height: 500px; height: 100%; width: 100%; min-width: 500px;"/>
  </div>
</template>

<style scoped>
</style>
