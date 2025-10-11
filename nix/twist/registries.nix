#
# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ inputs, emacsPackage, ... }:
[
  {
    name = "local";
    type = "melpa";
    path = ./recipes;
  }

  {
    name = "melpa";
    type = "melpa";
    path = inputs.melpa.outPath + "/recipes";
    exclude = [ "async" ];
  }

  {
    name = "gnu";
    type = "elpa";
    path = inputs.gnu-elpa.outPath + "/elpa-packages";
    core-src = emacsPackage.src;
    auto-sync-only = true;
    exclude = [
      "org-transclusion"
      "persist"
      "async"
    ];
  }

  {
    name = "gnu-archive";
    type = "archive";
    url = "https://elpa.gnu.org/packages/";
  }

  {
    name = "nongnu";
    type = "elpa";
    path = inputs.nongnu-elpa.outPath + "/elpa-packages";
  }

  {
    name = "nongnu-archive";
    type = "archive";
    url = "https://elpa.nongnu.org/nongnu/";
  }

]
