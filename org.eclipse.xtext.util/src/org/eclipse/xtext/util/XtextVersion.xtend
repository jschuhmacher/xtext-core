package org.eclipse.xtext.util

import java.io.IOException
import java.io.InputStream
import java.net.URL
import java.util.jar.Manifest
import org.eclipse.emf.common.EMFPlugin
import org.eclipse.xtend.lib.annotations.Data

/**
 * @since 2.9
 */
@Data
class XtextVersion {

	String version

	static def getCurrent() {
		new XtextVersion(readVersionFromManifest ?: 'unknown')
	}

	def getXtextGradlePluginVersion() {
		'2.0.2'
	}

	/**
	 * @noreference
	 */
	def getMweVersion() {
		'2.9.1.201705291010'
	}

	def getAntlrGeneratorVersion() {
		'2.1.1'
	}

	def getXtendGradlePluginVersion() {
		xtextGradlePluginVersion
	}

	/**
	 * @noreference
	 */
	def getXtendAndroidGradlePluginVersion() {
		xtendGradlePluginVersion
	}
	
	/**
	 * @return <code>true</code> if the current version ends with '-SNAPSHOT'
	 */
	def isSnapshot() {
		version.endsWith("-SNAPSHOT")
	}
	
	/**
	 * @return <code>true</code> if the current version is not a snapshot and not a release<br>
	 * 				Release builds must match a following pattern: N.N(.N)+<br>
	 *  			(N is a digit)<br>
	 * 				For example 2.9.2 is a release, 2.9.2.beta3 is stable.
	 */
	def isStable() {
		return !isSnapshot && !version.matches("\\d+\\.\\d+(\\.\\d+)+")
	}

	override toString() {
		version
	}

	private static def readVersionFromManifest() {
		var InputStream is
		try {
			val url = new URL(Plugin.INSTANCE.baseURL + 'META-INF/MANIFEST.MF')
			is = url.openStream()
			val manifest = new Manifest(is)
			var version = manifest.getMainAttributes().getValue('Maven-Version')
			// in dev mode, Maven-Version has the static value 'unspecified'
			// during a Gradle build that version gets replaced
			if ('unspecified' == version) {
				version = manifest.getMainAttributes().getValue('Bundle-Version')
				if (version.endsWith(".qualifier")) {
					return version.replace(".qualifier","-SNAPSHOT")
				} else {
					// strip off build qualifier
					return version.substring(0, version.lastIndexOf('.'))
				}
			}
			return version
		} catch (Exception e) {
			return null;
		} finally {
			if (is !== null) {
				try {
					is.close()
				} catch (IOException e) {
				}
			}
		}
	}

	private static class Plugin extends EMFPlugin {
		public static final Plugin INSTANCE = new Plugin

		private new() {
			super(#[]);
		}

		override getPluginResourceLocator() {
		}
	}

}
