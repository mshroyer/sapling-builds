Name: sapling
Version: %{ver}
Release: %{rel}%{?dist}
Summary: Sapling SCM
License: GPLv2
Group: Development/Tools
URL: https://github.com/mshroyer/sapling-builds
%{!?target_arch: %global target_arch noarch}
BuildArch: %{target_arch}
Requires: git
Requires: (libcurl or libcurl-minimal)
Requires: nodejs

%description
Unofficial build of the Sapling source control manager.

%prep
:

%build
:

%install
rm -rf %{buildroot}
install -Dm0755 %{_topdir}/BUILD/sl %{buildroot}%{_bindir}/sl
install -Dm0644 %{_topdir}/BUILD/isl-dist.tar.xz %{buildroot}/usr/lib/sapling/isl-dist.tar.xz

%files
%{_bindir}/sl
/usr/lib/sapling/isl-dist.tar.xz

%changelog
* Mon Nov 10 2025 Mark Shroyer <mark@shroyer.name> - 4.2.2-1
- Initial version
