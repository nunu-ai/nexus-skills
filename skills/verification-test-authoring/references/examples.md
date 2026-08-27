
## Example 1: Settings test

```jsonc
{
  "test": {
    "test_type": "verification",
    "name": "settings",
    "tags": [],
    "players_by_key": {
      "p1": {
        "name": "player 1",
        "agent_config_id": null,
        "game_funcs_config_id": null,
        "items_by_key": {
 
          "setup": {
            "type": "collection",
            "name": "standard setup",
            "steps_by_key": {
              "launch": {
                "goal": "Launch the app and wait until it finishes loading.",
                "expected_results": [
                  { "expected": "a 'Login' button and an SSO button are both visible." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "",
                    "content": [
                      "If a Terms of Service popup appears, tap 'I AGREE'.",
                      "Dismiss any news banner or popup that might appear." 
                    ] 
                  }
                ]
              },
              "failed-login": {
                "goal": "Tap Login and enter random wrong credentials",
                "expected_results": [
                  { "expected": "An error message is shown and you remain on the login screen (not logged in)." }
                ],
                "hint_manual": []
              },
              "login": {
                "goal": "Now try again and enter the provided credentials.",
                "expected_results": [
                  { "expected": "The main menu is shown after successfully logging in." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "",
                    "content": ["Avoid loging in with SSO, always use the provided minishop credentials"] }
                ]
              }
            },
            "step_order": ["launch", "failed-login", "login"]
          },
 
          "open_settings": {
            "type": "step",
            "goal": "Open the menu in the top-left, then tap Settings.",
            "expected_results": [
              { "expected": "The Settings screen is open." },
              { "expected": "The screen header text reads \"SETTINGS\"." },
              { "expected": "A back button is visible in the top-left corner." }
            ],
            "hint_manual": []
          },
 
          "settings_sections": {
            "type": "step",
            "goal": "Scroll the Settings screen from left to right.",
            "expected_results": [
              { "expected": "The tab labels ACCOUNT, SECURITY, LANGUAGE, NOTIFICATIONS, and PAYMENTS are each visible." },
              { "expected": "A version number and a build number are shown in the footer." }
            ],
            "hint_manual": []
          }
        },
        "item_order": ["setup", "open_settings", "settings_sections"]
      }
    },
    "player_order": ["p1"]
  },
  "folder_path": "daily-regression"
}
```

## Example 2: Testing 2 CRUD features

```jsonc
{
  "test": {
    "test_type": "verification",
    "name": "nexus - repo & build storage regression",
    "tags": ["repository", "build-storage"],
    "players_by_key": {
      "p1": {
        "name": "player 1",
        "agent_config_id": null,
        "game_funcs_config_id": null,
        "items_by_key": {

          "setup": {
            "type": "collection",
            "name": "standard setup",
            "is_shared": true,
            "steps_by_key": {
              "launch": {
                "goal": "Open the browser and navigate to the dev nexus environment following the nexus config knowledge file",
                "expected_results": [
                  { "expected": "The login screen is shown with a 'Login with nexus' button visible." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "Desktop / browser noise",
                    "content": [
                      "Close any system dialog blocking the view before opening the browser.",
                      "Dismiss any browser first-run wizard or 'save password' prompt."
                    ] }
                ]
              },
              "login": {
                "goal": "Tap 'Login with nexus' and enter the provided nexus credentials, then submit.",
                "expected_results": [
                  { "expected": "After submitting, the project-select screen is shown." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "Credential handling",
                    "content": ["Always use the provided nexus credentials. Do not tap 'Forgot Password'."] }
                ]
              },
              "select_project": {
                "goal": "Select the 'Playground' project.",
                "expected_results": [
                  { "expected": "The 'Playground' project dashboard is open." }
                ],
                "hint_manual": []
              }
            },
            "step_order": ["launch", "login", "select_project"]
          },

          "test_repository": {
            "type": "collection",
            "name": "Test Repository",
            "is_shared": false,
            "steps_by_key": {
              "create": {
                "goal": "Open Repository under Tests, click Create new, choose Verification agent, name it 'Daily Smoke Test Creation 1', set step 1 goal to 'Launch app and click Level 0', then click Update Test.",
                "expected_results": [
                  { "expected": "A test named 'Daily Smoke Test Creation 1' appears in the Repository list." }
                ],
                "hint_manual": []
              },
              "update": {
                "goal": "Edit 'Daily Smoke Test Creation 1', add the expected result 'Level 0 loads' to step 1, click Update Test, then reopen the test.",
                "expected_results": [
                  { "expected": "Reopening the test shows 'Level 0 loads' as step 1's expected result." }
                ],
                "hint_manual": []
              },
              "move": {
                "goal": "Select the test's checkbox, click Move, and choose the 'Daily Smoke Test' folder.",
                "expected_results": [
                  { "expected": "The test appears inside the 'Daily Smoke Test' folder." }
                ],
                "hint_manual": []
              },
              "delete": {
                "goal": "Inside the 'Daily Smoke Test' folder, select the test's checkbox and click Delete.",
                "expected_results": [
                  { "expected": "The test no longer appears in the Repository." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "Delete guardrail",
                    "content": ["Delete only 'Daily Smoke Test Creation 1' and nothing else."] }
                ]
              }
            },
            "step_order": ["create", "update", "move", "delete"]
          },

          "build_storage": {
            "type": "collection",
            "name": "Build Storage",
            "is_shared": false,
            "steps_by_key": {
              "upload": {
                "goal": "Open Build Storage, click Upload Build, select the downloaded .apk, and name it 'Smoke Check Test Upload'.",
                "expected_results": [
                  { "expected": "A build named 'Smoke Check Test Upload' appears in Build Storage." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "Where to get the build",
                    "content": ["Download the APK first following the debug-builds.md knowledge file"] }
                ]
              },
              "manage": {
                "goal": "On 'Smoke Check Test Upload', click View Build Details, close the popup, open the three-dots menu and choose Pin build, then click the pencil icon.",
                "expected_results": [
                  { "expected": "View Build Details opens a popup showing the build's details." },
                  { "expected": "After choosing Pin build, the build is shown as pinned." },
                  { "expected": "Clicking the pencil icon opens an Edit Build popup." }
                ],
                "hint_manual": []
              },
              "delete": {
                "goal": "Select the 'Smoke Check Test Upload' checkbox and click Delete.",
                "expected_results": [
                  { "expected": "The build no longer appears in Build Storage." }
                ],
                "hint_manual": [
                  { "hint_key_regex": ".*",
                    "description": "Delete guardrail",
                    "content": ["Delete only 'Smoke Check Test Upload' and nothing else."] }
                ]
              }
            },
            "step_order": ["upload", "manage", "delete"]
          }
        },
        "item_order": ["setup", "test_repository", "build_storage"]
      }
    },
    "player_order": ["p1"]
  },
  "folder_path": "release-sanity"
}
```
