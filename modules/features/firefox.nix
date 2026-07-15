_: {
  flake.modules.homeManager.firefox = {
    programs.firefox = {
      enable = true;
      profiles.default = {
        settings = {
          "browser.newtabpage.enabled" = false;
          "browser.startup.homepage" = "about:blank";

          "layout.css.devPixelsPerPx" = "1.1";
          "privacy.globalprivacycontrol.enabled" = true;
          "signon.firefoxRelay.feature" = "disabled";
          "signon.rememberSignons" = false;
          "signon.management.page.breach-alerts.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.formautofill.addresses.enabled" = false;

          "browser.startup.page" = 3;
          "ui.key.menuAccessKeyFocuses" = false;
          "media.hardwaremediakeys.enabled" = false;
          "browser.ml.chat.enabled" = false;
          "browser.ml.enabled" = false;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "browser.urlbar.quicksuggest.enabled" = false;
          "browser.urlbar.suggest.engines" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "media.eme.enabled" = true;
          "accessibility.typeaheadfind" = true;
          "network.trr.mode" = 5;
          "media.autoplay.default" = 5;
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.closeWindowWithLastTab" = false;
          "extensions.pocket.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;

          # What to sync
          "services.sync.prefs.sync.browser.uiCustomization.state" = true;
          "services.sync.prefs.sync.browser.uiCustomization.navBarWhenVerticalTabs" = true;
          "services.sync.prefs.sync.sidebar.main.tools" = true;
          "services.sync.prefs.sync.sidebar.position_start" = true;
          "services.sync.prefs.sync.sidebar.visibility" = true;
          "services.sync.prefs.sync.browser.toolbars.bookmarks.visibility" = true;
          "services.sync.prefs.sync.browser.download.autohideButton" = true;
        };
      };
    };
  };
}
