#
# spec file for package yast2-alternatives
#
# Copyright (c) 2016 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           yast2-alternatives
Version:        4.1.0
Release:        0
License:        GPL-2.0
Summary:        YaST2 - Manage Update-alternatives switching
Url:            https://github.com/yast/yast-alternatives
Group:          System/Yast
Source0:        %{name}-%{version}.tar.bz2
BuildRequires:  yast2
BuildRequires:  yast2-devtools
BuildRequires:  yast2-ruby-bindings
# For install
BuildRequires:  rubygem(yast-rake)
# For test
BuildRequires:  rubygem(rspec)
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
A YaST2 module to manage update alternatives switching
%prep
%setup -n %{name}-%{version}

%build

%check
rake test:unit

%install
rake install DESTDIR=%{buildroot}

%post

%postun

%files
%defattr(-,root,root)
%{yast_dir}/clients/*.rb
%{yast_dir}/lib/y2_alternatives/
%{yast_dir}/lib/y2_alternatives/dialog
%{yast_dir}/lib/y2_alternatives/control
%{yast_desktopdir}/alternatives.desktop
%{_datadir}/icons/*
%doc COPYING
%doc README.md
