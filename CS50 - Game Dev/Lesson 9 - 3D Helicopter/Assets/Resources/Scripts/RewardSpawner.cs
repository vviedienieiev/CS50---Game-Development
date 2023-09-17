using UnityEngine;
using System.Collections;

public class RewardSpawner : MonoBehaviour {

	public GameObject[] prefabs;
	public int DiamondChance = 5;

	// Use this for initialization
	void Start () {

		// infinite coin spawning function, asynchronous
		StartCoroutine(SpawnRewards());
	}

	// Update is called once per frame
	void Update () {

	}

	IEnumerator SpawnRewards() {
		while (true) {

			// number of coins we could spawn vertically
			int coinsThisRow = Random.Range(1, 4);

			// instantiate all coins in this row separated by some random amount of space
			for (int i = 0; i < coinsThisRow; i++) {
				if (Random.Range(0, 100) <= DiamondChance){
					Instantiate(prefabs[1], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
				}
				else
				{
					Instantiate(prefabs[0], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
				}
			}

			// pause 1-5 seconds until the next coin spawns
			yield return new WaitForSeconds(Random.Range(1, 5));
		}
	}
}
