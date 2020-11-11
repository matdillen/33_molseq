from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('<int:run_id>/', views.detail, name='detail'),
    path('create', views.create, name='create'),
    path('about', views.about, name='about'),
]