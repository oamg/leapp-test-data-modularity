Name:           nonmodule-inmoduleD
Version:        1.0.0
Release:        1%{?dist}
Summary:        Package that should be nonmodule and become modular

License:        MIT
URL:            https://gitlab.cee.redhat.com/leapp/leapp-tests-modularity
BuildArch:      noarch

%if 0%{?rhel} == 9
ModularityLabel: inmoduleD:devel:1
%endif


%description
%{summary}


%prep

%build

%install

%files


%changelog
* Mon Jul 19 2021 Petr Stodulka <pstodulk@redhat.com>
- Heya!
