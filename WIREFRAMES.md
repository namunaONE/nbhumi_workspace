# WIREFRAMES.md — nBhumi Key Screens

> ASCII sketches of the five golden screens, showing **compact** and
> **expanded** variants. Source files are named beside each so the sketch can
> be checked against the implementation.
>
> The five screens are the ones under `apps/user_app/test/goldens/ci/`
> (× light/dark × compact/expanded = 20 images).

---

## Screen inventory

| # | Screen | Route | Chrome owner |
|---|---|---|---|
| 1 | Explore (home) | `/` | Shell (tab) |
| 2 | Explore — Search | `/search` → `/` (legacy redirect) | Shell (tab) |
| 3 | Listing detail | `/listing/:id` | Root navigator — owns its chrome |
| 4 | Post listing wizard | `/post` | Root navigator — owns its chrome |
| 5 | Profile | `/profile` | Shell (tab) |

Explore and Search are **one screen**: `SearchScreen` at `/`. `/search` is a
legacy path that `redirect` maps to `/` before anything renders — one feed,
one filter state, no tab switch needed.

Screens 3 and 4 sit outside the shell on the root navigator, so they cover the
tab bar. Detail does this because any tab may open a listing; a route nested
in one branch would be invisible to the others. Post does it because the
wizard owns its own progress indicator.

---

## 1. Explore (home)

`features/search/lib/src/presentation/search_screen.dart`

### Compact (<600)

```
┌─────────────────────────────┐
│ Explore            🔔       │  AppBar — shell title + NotificationBell
├─────────────────────────────┤
│ [ 🔍 Search Kathmandu…   ] │  Query field
├─────────────────────────────┤
│ ◄ Featured carousel ►       │  Only when the filter is empty —
├─────────────────────────────┤  narrow results must not push matches down
│ sort ▾   ⚙ Filters        │  Sort + filter + grid/list toggle
├─────────────────────────────┤
│ ┌────────┐  ┌────────┐     │
│ │  photo │  │  photo │     │  1–2 columns, from ListingGrid.columnsFor
│ │        │  │        │     │
│ └────────┘  └────────┘     │
│ [Buy]              ✓verif  │  Purpose chip top-left, badge top-right
│ NPR 1,25,00,000            │
│ Kathmandu · 4 anna         │  Area merges into the location line
│ ┌────────┐  ┌────────┐     │
│ │        │  │        │     │
│ └────────┘  └────────┘     │
│           …                │
│         ( spinner )        │  while a page loads
├─────────────────────────────┤
│ ⬤ Explore ⬤ Saved  (+) My ⬤ Profile │  Notched BottomAppBar, post centre-docked
└─────────────────────────────┘
```

### Expanded (≥840)

```
┌──────────────────────────────────────────────────────┐
│ ┌──────────────┐ │ Explore            🔔            │
│ │  nBhumi      │ ├──────────────────────────────────┤
│ │              │ │ [ 🔍 Search Kathmandu…        ]  │
│ │ + Post       │ ├──────────────────────────────────┤
│ │ ● Explore    │ │ ◄ Featured carousel ►            │
│ │ ○ Saved      │ ├──────────────────────────────────┤
│ │ ○ My Listings│ │ sort ▾   ⚙ Filters              │
│ │ ○ Profile    │ ├───────────────┬──────────────────┤
│ │              │ │ ┌───────────┐ │                  │
│ │              │ │ │  photo    │ │  Listing detail   │
│ │              │ │ └───────────┘ │  pane             │
│ │              │ │ [Buy]  NPR…  │ │                  │
│ │              │ │ ┌───────────┐ │ │  ✕ closes,       │
│ │              │ │ │           │ │ │ │  keeps feed     │
│ └──────────────┘ └─────────────┴─────────────────────┘
│  NavigationDrawer 220px   feed capped at 960px       │
└──────────────────────────────────────────────────────┘
```

At **medium** (600–839) the drawer is a `NavigationRail` instead, with the
post action in its trailing slot. The tab content is never reset by a resize —
the same `navigationShell` is reused, so tab stacks and scroll positions
survive.

---

## 2. The listing card

`packages/core/lib/src/widgets/listing_card.dart`

```
┌──────────────────┐
│                  │
│  4:3 cover photo │  shimmer while loading, failure
│      (AppImage)  │  state on error
│                  │
├──────────────────┤
│ [Buy]            │  purpose chip — photo only, never
│ NPR 1,25,00,000  │  repeated in the body (a full row)
│ Kathmandu ·      │  per card)
│   4 anna · Land  │  type chip beside the verified badge;
└──────────────────┤  area merges into the location line
```

**Density is automatic, not a breakpoint.** `ListingGrid` computes the column
count from a minimum card width, then flags `compact` when the resulting card
drops under 220px. One card, correct on every width.

---

## 3. Listing detail

`features/listing_detail/lib/src/presentation/`

```
┌─────────────────────────────┐
│ ←                    ⤴ ✕   │  Full-screen chrome; ✕ only in the
├─────────────────────────────┤  side-pane variant
│ ┌────────┐┌────────┐        │
│ │ photo  ││ photo  │        │  photo strip (horizontal)
│ └────────┘└────────┘        │
│ NPR 1,25,00,000    [Buy]    │
│ Kathmandu-16, Ward 3        │  district → municipality → ward
│ ✓ KYC verified seller       │
├─────────────────────────────┤
│ Bedrooms    3               │  WIREFRAMES Screen 2 rows
│ Bathrooms   2               │
│ Area        4 anna          │  ropani-aana-paisa-dam (hill)
├─────────────────────────────┤  or bigha-kattha-dhur (terai)
│ Description…                │
├─────────────────────────────┤
│ Owner actions: Edit/Remove  │  only when the viewer is the owner
└─────────────────────────────┘
```

**Public route.** A guest must be able to open a listing from a shared link
without signing in first — `/listing/:id` is in `kPublicRoutes`, and RLS
permits SELECT on live listings only.

---

## 4. Post listing wizard

`features/post_listing/lib/src/presentation/`

```
┌─────────────────────────────┐
│ ←                Step 2 of 4│  Outside the shell — owns chrome and
├─────────────────────────────┤  its own progress indicator
│  ●───○───○───○              │
├─────────────────────────────┤
│ Purpose:  ( ) Buy  ( ) Rent  │
├─────────────────────────────┤
│ Location                    │
│  District     [Kathmandu ▾]  │
│  Municipality [KMC ▾]        │
│  Ward         [3    ]        │  1–33, optional
├─────────────────────────────┤
│ Area                        │
│  4 anna                     │  hill / terai units convertible
├─────────────────────────────┤
│  [ Continue ]               │
└─────────────────────────────┘
```

Gated: posting is the one action that genuinely requires an account, so a
guest is redirected to `/login`.

The set of fields shown depends on purpose and property type — a rental asks
for rent terms a sale does not, so the later steps are conditioned rather than
one long static form.

---

## 5. Profile

`apps/user_app/lib/screens/profile_screen.dart`

```
┌─────────────────────────────┐
│ Profile                     │
├─────────────────────────────┤
│ ┌───────────────────────┐   │
│ │ 👤  Name              │   │
│ │     98XXXXXXXX   ✓ver │   │  Nepali mobile format
│ └───────────────────────┘   │
├─────────────────────────────┤
│ ⚙ Settings                › │
│ 🔔 Activity                › │
├─────────────────────────────┤
│ My listings    ( 3 )        │
│ Post a listing              │
├─────────────────────────────┤
│  Sign in                    │  guest state, not an empty screen
└─────────────────────────────┘
```

**Profile is deliberately public** — it is a bottom-nav destination, so
bouncing a guest to login the moment they tap it is jarring when the screen can
show a perfectly good signed-out state with a sign-in prompt.

`/profile/settings` and `/profile/activity` push on the **root** navigator, so
they cover the tab bar.

---

## Responsive rules (summary)

| Rule | Where it lives |
|---|---|
| Navigation affordance switches at 600 / 840 | `AppBreakpoints.medium` / `.expanded` |
| Detail side pane appears at 1000 | `AppBreakpoints.twoPane` |
| Feed column count comes from min card width, not a breakpoint | `ListingGrid.columnsFor` |
| Feed content caps at 960px on wide windows | `AppSizes.contentMaxWidth` |
| Grid/vlist toggle is local UI state, never global | `_SearchScreenState._layout` |

See **DESIGN.md §6** for the reasoning and the forbidden `LayoutBuilder`
patterns behind these numbers.
