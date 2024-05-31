import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/sign-up',
      name: 'Sign up',
      component: () => import('../views/SignUpView.vue')
    },
    {
      path: '/sign-in',
      name: 'Sign in',
      component: () => import('../views/SignInView.vue')
    },
    {
      path: '/my-announcements',
      name: 'My announcements',
      component: () => import('../views/MyAnnouncementsView.vue')
    },
    {
      path: '/my-announcements/:id',
      name: 'My announcement details',
      component: () => import('../views/MyAnnouncementDetailsView.vue')
    }
  ]
})

export default router
