Name:      simengine-core
Version:   3.42
Release:   6%{?dist}
Summary:   SimEngine - Core
URL:       https://github.com/Seneca-CDOT/simengine
License:   GPLv3+

%global gittag %{version}
%global selected_libdir /usr/lib64

Source0: https://github.com/Seneca-CDOT/simengine/archive/%{gittag}/simengine-%{version}.tar.gz

Patch1:  0001-simengine-upstream.patch
Patch2:  0002-simengine-upstream.patch
Patch3:  0003-simengine-upstream.patch
Patch4:  0004-simengine-upstream.patch
Patch5:  0005-simengine-upstream.patch
Patch6:  0006-simengine-upstream.patch
Patch7:  0007-simengine-upstream-python39.patch
Patch8:  0008-ipmi-sim-enable-debug-log.patch
Patch9:  0009-ipmi-sim-fix-memory-init.patch
Patch10: 0010-ipmi-sim-fix-return-vs-exit.patch
Patch11: 0011-simengine-debug-log.patch
Patch12: 0012-ipmi-sim-read-ip-from-conf.patch

BuildRequires: OpenIPMI-devel, gcc

Requires: simengine-database
Requires: python3-libvirt
Requires: OpenIPMI
Requires: OpenIPMI-lanserv
Requires: python3-redis
Requires: python3-pysnmp
Requires: python3-neo4j-driver
Requires: python3-websocket-client
Requires: python3-circuits
Requires: python3-snmpsim

%description
Core files for SimEngine.

%global debug_package %{nil}

%preun
systemctl disable %{name}.service --now

%prep
%autosetup -p 1 -n simengine-%{version}

%build
openipmi_version=$(rpm -q --qf "%%{VERSION}" OpenIPMI-devel)
define_openipmi_post_2_0_30=$([[ "$openipmi_version" > "2.0.30" ]] && printf "%s" "-D OPENIPMI_POST_2_0_30")
gcc \
    -shared \
    -o %{_builddir}/simengine-%{version}/haos_extend.so \
    -fPIC \
    $define_openipmi_post_2_0_30 \
    %{_builddir}/simengine-%{version}/enginecore/ipmi_sim/haos_extend.c

%install
mkdir -p %{buildroot}%{_datadir}/simengine/
mkdir -p %{buildroot}%{selected_libdir}/simengine/
mkdir -p %{buildroot}%{selected_libdir}/systemd/system/
mkdir -p %{buildroot}/usr/lib/systemd/system/  # in case selected_libdir is different
mkdir -p %{buildroot}%{_bindir}/
cp -fp haos_extend.so %{buildroot}%{selected_libdir}/simengine/
cp -fRp enginecore %{buildroot}%{_datadir}/simengine/
cp -fRp data %{buildroot}%{_datadir}/simengine/
cp -fp services/%{name}.service %{buildroot}/usr/lib/systemd/system/
ln -s /usr/share/simengine/enginecore/simengine-cli %{buildroot}%{_bindir}/simengine-cli
mkdir -p %{buildroot}%{_localstatedir}/log/simengine
exit 0

%files
%{selected_libdir}/simengine/haos_extend.so
%{_datadir}/simengine/enginecore
%{_datadir}/simengine/data
/usr/lib/systemd/system/%{name}.service
%{_bindir}/simengine-cli
%{_localstatedir}/log/simengine
%ghost %{_localstatedir}/log/simengine/*

%post
systemctl daemon-reload
systemctl enable %{name}.service --now

%postun
systemctl daemon-reload

%changelog
* Sun Apr 07 2024 Fabio M. Di Nitto <fabbione@fabbione.net> - 3.42-6
- enable debug logging by default
- ipmi_sim: use lan.conf to report ip address

* Sun Mar 24 2024 Fabio M. Di Nitto <fabbione@fabbione.net> - 3.42-5
- fix ipmi_sim plugin exit vs return code

* Sun Mar 24 2024 Fabio M. Di Nitto <fabbione@fabbione.net> - 3.42-4
- add ipmi_sim plugin memory init

* Sat Mar 02 2024 Fabio M. Di Nitto <fabbione@fabbione.net> - 3.42-3
- add ipmi_sim debug logging

* Mon Jan 08 2024 Fabio M. Di Nitto <fabbione@fabbione.net> - 3.42-2
- add all unreleased upstream changes
- add support for python3.9

* Fri Jan 20 2023 Chris Tyler <chris@tylers.info> - 3.42-1
- new version

* Thu Jan 19 2023 Chris Tyler <chris@tylers.info> - 3.41-1
- new version

* Wed Dec 07 2022 Tanner Moss <tmoss404@gmail.com> - 3.40-1
- new version

* Wed Nov 30 2022 Tanner Moss <tmoss404@gmail.com> - 3.39-1
- new version

* Mon Aug 23 2021 Tsu-ba-me <ynho.li.aa.e@gmail.com> - 3.38-1
- new version

* Fri Aug 06 2021 Tsu-ba-me <ynho.li.aa.e@gmail.com> - 3.37-1
- new version

* Mon Dec 07 2020 Tsu-ba-me <ynho.li.aa.e@gmail.com> - 3.36-1
- new version

* Wed May 06 2020 Yanhao Lei <ynho.li.aa.e@gmail.com> - 3.33-1
- new version

* Thu Jan 23 2020 Yanhao Lei <ynho.li.aa.e@gmail.com> - 3.32-1
- new version

* Wed Jan 08 2020 Yanhao Lei <ynho.li.aa.e@gmail.com> - 3.31-1
- new version

* Mon Jan 06 2020 Yanhao Lei <ynho.li.aa.e@gmail.com> - 3.30-1
- new version

* Wed Dec 11 2019 Yanhao Lei <ynho.li.aa.e@gmail.com> - 3.29-1
- new version

* Mon Dec 02 2019 Yanhao Lei <ynho.li.aa.e@gmail.com> - 3.28-1
- new version

* Thu Oct 03 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.27-1
- new version

* Thu Aug 08 2019 Olga Belavina <ol.belavina@gmail.com> - 3.26-1
- new version

* Tue Apr 30 2019 Olga Belavina <ol.belavina@gmail.com> - 3.25-1
- new version

* Mon Apr 29 2019 Olga Belavina <ol.belavina@gmail.com> - 3.24-1
- new version

* Fri Apr 26 2019 Olga Belavina <ol.belavina@gmail.com> - 3.23-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.21-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.20-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.19-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.18-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.17-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.16-1
- new version

* Fri Mar 15 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.15-1
- new version

* Mon Mar 11 2019 Chris Tyler - 3.11-1
- new version

* Mon Mar 11 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.10-1
- new version

* Mon Mar 11 2019 Chris Tyler <ctyler.fedora@gmail.com> - 3.8-1
- new version

* Fri Mar 01 2019 Chris Tyler <chris.tyler@senecacollege.ca> - 3.7-3
- Updated for simengine 3.7

* Thu Aug 23 2018 Chris Johnson <chris.johnson@senecacollege.ca>
- Converted paths to macros where applicable
- Changed source to GitHub URL using gittag release version

* Thu Aug 16 2018 Chris Johnson <chris.johnson@senecacollege.ca>
- Updated dependencies

* Mon Jul 23 2018 Chris Johnson <chris.johnson@senecacollege.ca>
- Initial alpha test file
