Name: sapling
Version: %{ver}
Release: %{rel}%{?dist}
Summary: Sapling SCM
License: GPLv2
Group: Development/Tools
URL: https://github.com/mshroyer/sapling-builds
BuildArch: x86_64
Requires: git
Requires: nodejs

%description
Unofficial build of the Sapling source control manager.

%prep
:

%build
:

%install
rm -rf %{buildroot}
install -Dm0755 sl %{buildroot}%{_bindir}/sl
install -Dm0644 isl-dist.tar.xz %{buildroot}/usr/lib/sapling/isl-dist.tar.xz

%files
%{_bindir}/sl
/usr/lib/sapling/isl-dist.tar.xz

%changelog
* Mon Nov 10 2025 Mark Shroyer <mark@shroyer.name> - 4.2.2-1
- Initial version
