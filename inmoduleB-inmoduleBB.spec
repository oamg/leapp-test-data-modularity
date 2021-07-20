Name:           inmoduleB-inmoduleBB
Version:        1.0.0
Release:        1%{?dist}
Summary:        Package that should be in a module and become part of another module

License:        MIT
URL:            https://gitlab.cee.redhat.com/leapp/leapp-tests-modularity
BuildArch:      noarch

%if 0%{?rhel} == 8
ModularityLabel: inmoduleB:devel:1
%else
# RHEL 9
ModularityLabel: inmoduleBB:devel:1
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
