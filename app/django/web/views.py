from django.shortcuts import render
from django.views.generic.list import ListView
from django.views.generic.detail import DetailView
from .models import MatchingRun


class MatchingRunListView(ListView):
    model = MatchingRun
    queryset = MatchingRun.objects.all().values('id', 'ena_query', 'gbif_query', 'created')


class MatchingRunDetailView(DetailView):
    model = MatchingRun


def detail(request, run_id):
    return render(request, 'web/detail.html', {})


def create(request):
    return render(request, 'web/create.html', {})


def about(request):
    return render(request, 'web/about.html', {})
