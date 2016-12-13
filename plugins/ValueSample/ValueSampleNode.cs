#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "Sample", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueSampleNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		public ISpread<Vector3D> Positions;
		
		[Input("Vector")]
		public ISpread<Vector3D> Vec;

		[Output("Output")]
		public ISpread<Vector3D> FOutput;
		
		[Output("Origins")]
		public ISpread<Vector3D> Origins;
		
		private ISpread<Vector3D> CurrentPositions;
		private Boolean isFirst = true;
		[Import()]
		public ILogger FLogger;
		#endregion fields & pins
		
		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if(isFirst) {
				CurrentPositions = Positions.Clone();
				isFirst = false;
			}
			
			FOutput.SliceCount = SpreadMax;

			 for (int i = 0; i < SpreadMax; i++) {
			 	FOutput[i] = CurrentPositions[i] + Vec[i];
			 	Origins[i] = Positions[i];
			 	CurrentPositions[i] = FOutput[i];
			 }
				
			//FLogger.Log(LogType.Debug, "hi tty!");
		}
	}
}
