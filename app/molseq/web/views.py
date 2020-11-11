from django.shortcuts import render


def index(request):
    return render(request, 'web/index.html', {})


def detail(request, run_id):
    return render(request, 'web/detail.html', {})


def create(request):
    return render(request, 'web/create.html', {})


def about(request):
    return render(request, 'web/about.html', {})
