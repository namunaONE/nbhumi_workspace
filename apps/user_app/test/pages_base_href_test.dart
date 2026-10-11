// Guards the GitHub Pages base-href contract.
//
// The failure this exists to catch: a base of "/" on a Pages *project* site
// makes the browser request /main.dart.js, which 404s, so the app renders a
// blank canvas while the HTML banner still paints. That is exactly how the
// first deploy shipped — a green workflow and a white screen — because
// base-href governs asset URL resolution and has nothing to do with the hash
// routing the app uses.
//
// The deploy workflow passes /<repo>/ (derived from github.event.repository
// .name). These tests assert the shape of that contract rather than the repo
// name, so a rename, a fork, or a move to a user site or custom domain all
// surface here as a deliberate edit instead of a silent 404.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Repo path Pages project sites are served under.
const String _pagesRepoPath = '/nbhumi_workspace/';

void main() {
  late String workflow;

  setUp(() {
    workflow = File('.github/workflows/deploy-preview.yml').readAsStringSync();
  });

  group('deploy-preview workflow base-href', () {
    test('does not build with base-href /', () {
      // A bare "/" is only valid for a user site or a custom domain.
      expect(
        RegExp(r'--base-href\s+/[\s\\]').hasMatch(workflow),
        isFalse,
        reason: 'base-href / 404s every asset on a Pages project site',
      );
    });

    test('builds with the repo path as base-href', () {
      expect(
        workflow.contains(
          r'--base-href /${{ github.event.repository.name }}/',
        ),
        isTrue,
        reason: 'Pages project sites serve from /<repo>/',
      );
    });

    test('resolves to the published path for this repo', () {
      const repoName = 'nbhumi_workspace';
      expect('/$repoName/', _pagesRepoPath);
    });
  });

  group('deployed index.html', () {
    // Only meaningful when a build has been produced locally. The workflow
    // runs its own build, so this is a local-dev convenience assertion rather
    // than a CI gate.
    test('built index.html carries the repo base-href, not /', () {
      final built = File('apps/user_app/build/web/index.html');
      if (!built.existsSync()) {
        // Not a failure: no local build present.
        return;
      }

      final html = built.readAsStringSync();
      final match = RegExp('<base href="([^"]*)"').firstMatch(html);
      expect(match, isNotNull, reason: 'built index.html has no base href');

      final href = match!.group(1);
      expect(
        href,
        _pagesRepoPath,
        reason:
            'base href "$href" would make the browser request '
            '/main.dart.js, which 404s on Pages. Rebuild with '
            '--base-href $_pagesRepoPath.',
      );
    });
  });
}
