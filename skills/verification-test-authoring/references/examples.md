# Worked examples

These are JSONC-style payloads for `create_verification_test`. Replace
`<project-id>` when credentials can access multiple projects. Replace
`<agent-config-id>` with an ID from `list_project_resources` using
`resource: "agent_configs"`. Replace `<shared-step-id>` with an ID returned by
`list_shared_steps`.

The create payload is not the same as `get_test` output: do not add a `test`
wrapper, `test_type`, server-assigned IDs, or read-only collection fields.

## Example 1: Settings test

```jsonc
{
  "project_id": "<project-id>",
  "name": "settings",
  "tags": [],
  "folder_path": "daily-regression",
  "budget": { "max_seconds": 900 },
  "players": [
    {
      "name": "player 1",
      "agent_config_id": "<agent-config-id>",
      "items": [
        {
          "type": "collection",
          "name": "standard setup",
          "steps": [
            {
              "instruction": "Launch the app and wait until it finishes loading.",
              "expected_results": [
                "A 'Login' button and an SSO button are both visible."
              ],
              "hints": [
                "If a Terms of Service popup appears, tap 'I AGREE'.",
                "Dismiss any news banner or popup that might appear."
              ]
            },
            {
              "instruction": "Tap Login and enter random wrong credentials.",
              "expected_results": [
                "An error message is shown and you remain on the login screen (not logged in)."
              ],
              "hints": []
            },
            {
              "instruction": "Try again and enter the provided credentials.",
              "expected_results": [
                "The main menu is shown after successfully logging in."
              ],
              "hints": [
                "Avoid logging in with SSO; always use the provided minishop credentials."
              ]
            }
          ]
        },
        {
          "type": "step",
          "instruction": "Open the menu in the top-left, then tap Settings.",
          "expected_results": [
            "The Settings screen is open.",
            "The screen header text reads \"SETTINGS\".",
            "A back button is visible in the top-left corner."
          ],
          "hints": []
        },
        {
          "type": "step",
          "instruction": "Scroll the Settings screen from left to right.",
          "expected_results": [
            "The tab labels ACCOUNT, SECURITY, LANGUAGE, NOTIFICATIONS, and PAYMENTS are each visible.",
            "A version number and a build number are shown in the footer."
          ],
          "hints": []
        }
      ]
    }
  ]
}
```

## Example 2: Testing 2 CRUD features

This example uses a shared setup collection by reference. The shared steps live
in the shared-step resource; they are not copied into this test.

```jsonc
{
  "project_id": "<project-id>",
  "name": "nexus - repo & build storage regression",
  "tags": ["repository", "build-storage"],
  "folder_path": "release-sanity",
  "budget": { "max_seconds": 19800 },
  "players": [
    {
      "name": "player 1",
      "agent_config_id": "<agent-config-id>",
      "items": [
        {
          "type": "shared_steps",
          "shared_collection_id": "<shared-step-id>"
        },
        {
          "type": "collection",
          "name": "Test Repository",
          "steps": [
            {
              "instruction": "Open Repository under Tests, click Create new, choose Verification agent, name the test 'Daily Smoke Test Creation 1', set step 1 instruction to 'Launch app and click Level 0', then click Update Test.",
              "expected_results": [
                "A test named 'Daily Smoke Test Creation 1' appears in the Repository list."
              ],
              "hints": []
            },
            {
              "instruction": "Edit 'Daily Smoke Test Creation 1', add the expected result 'Level 0 loads' to step 1, click Update Test, then reopen the test.",
              "expected_results": [
                "Reopening the test shows 'Level 0 loads' as step 1's expected result."
              ],
              "hints": []
            },
            {
              "instruction": "Select the test's checkbox, click Move, and choose the 'Daily Smoke Test' folder.",
              "expected_results": [
                "The test appears inside the 'Daily Smoke Test' folder."
              ],
              "hints": []
            },
            {
              "instruction": "Inside the 'Daily Smoke Test' folder, select the test's checkbox and click Delete.",
              "expected_results": [
                "The test no longer appears in the Repository."
              ],
              "hints": [
                "Delete only 'Daily Smoke Test Creation 1' and nothing else."
              ]
            }
          ]
        },
        {
          "type": "collection",
          "name": "Build Storage",
          "steps": [
            {
              "instruction": "Open Build Storage, click Upload Build, select the downloaded .apk, and name it 'Smoke Check Test Upload'.",
              "expected_results": [
                "A build named 'Smoke Check Test Upload' appears in Build Storage."
              ],
              "hints": [
                "Download the APK first following the debug-builds.md knowledge file."
              ]
            },
            {
              "instruction": "On 'Smoke Check Test Upload', click View Build Details, close the popup, open the three-dots menu and choose Pin build, then click the pencil icon.",
              "expected_results": [
                "View Build Details opens a popup showing the build's details.",
                "After choosing Pin build, the build is shown as pinned.",
                "Clicking the pencil icon opens an Edit Build popup."
              ],
              "hints": []
            },
            {
              "instruction": "Select the 'Smoke Check Test Upload' checkbox and click Delete.",
              "expected_results": [
                "The build no longer appears in Build Storage."
              ],
              "hints": [
                "Delete only 'Smoke Check Test Upload' and nothing else."
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

For a multiplayer test, add more entries to `players`. Each player has its own
agent config and ordered item list; use a shared collection reference when the
same setup must run for every player.
