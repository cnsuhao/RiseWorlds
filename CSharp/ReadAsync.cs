using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;

class Async
{
	public async void ProcessRead()
	{
		string filePath = @"temp2.txt";

		if (File.Exists(filePath) == false)
		{
			Debug.WriteLine("file not found: " + filePath);
		}
		else
		{
			try
			{
				string text = await ReadTextAsync(filePath);
				Debug.WriteLine(text);
			}
			catch (Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
		}
	}

	private async Task<string> ReadTextAsync(string filePath)
	{
		using (FileStream sourceStream = new FileStream(filePath,
			FileMode.Open, FileAccess.Read, FileShare.Read,
			bufferSize: 4096, useAsync: true))
		{
			StringBuilder sb = new StringBuilder();

			byte[] buffer = new byte[0x1000];
			int numRead;
			while ((numRead = await sourceStream.ReadAsync(buffer, 0, buffer.Length)) != 0)
			{
				string text = Encoding.Unicode.GetString(buffer, 0, numRead);
				sb.Append(text);
			}

			return sb.ToString();
		}
	}
	
	static void Main()
	{
		Async myAsync = new Async();
		myAsync.ProcessRead();
	}
}