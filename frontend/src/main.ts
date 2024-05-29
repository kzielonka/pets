import './assets/main.css';
import 'primevue/resources/themes/aura-light-green/theme.css';

import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import PrimeVue from 'primevue/config';
import 'vue3-openlayers/styles.css';

import OpenLayersMap from 'vue3-openlayers';

const app = createApp(App);

app.use(router);
app.use(PrimeVue);
app.use(OpenLayersMap /*, options */);

app.mount('#app');
